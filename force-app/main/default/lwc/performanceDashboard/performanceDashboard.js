import { LightningElement, track, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getSystemHealth from '@salesforce/apex/ENOS_PerformanceMonitor.getSystemHealth';
import getPerformanceMetrics from '@salesforce/apex/ENOS_AdvancedDynamicUtils.getPerformanceMetrics';
import getSalesAnalytics from '@salesforce/apex/ENOS_AdvancedAnalyticsService.getSalesAnalytics';
import getProductPerformanceAnalytics from '@salesforce/apex/ENOS_AdvancedAnalyticsService.getProductPerformanceAnalytics';
import getInventoryAnalytics from '@salesforce/apex/ENOS_AdvancedAnalyticsService.getInventoryAnalytics';
import EnosBaseComponent from 'c/enosBaseComponent';

export default class PerformanceDashboard extends EnosBaseComponent {
    @api refreshInterval = 30000; // 30 seconds default
    @track systemHealth;
    @track performanceMetrics;
    @track salesAnalytics;
    @track productAnalytics;
    @track inventoryAnalytics;
    @track isLoading = true;
    @track error;
    @track selectedTimeRange = '30D';
    @track selectedCategory = 'all';
    
    // Performance monitoring
    refreshIntervalId;
    
    // Wire configurations
    wiredSystemHealth;
    wiredPerformanceMetrics;
    wiredSalesAnalytics;
    wiredProductAnalytics;
    wiredInventoryAnalytics;
    
    // Time range options
    timeRangeOptions = [
        { label: 'Last 7 Days', value: '7D' },
        { label: 'Last 30 Days', value: '30D' },
        { label: 'Last 90 Days', value: '90D' },
        { label: 'Last Year', value: '1Y' }
    ];
    
    // Category options
    categoryOptions = [
        { label: 'All Categories', value: 'all' },
        { label: 'Audio', value: 'Audio' },
        { label: 'Computing', value: 'Computing' },
        { label: 'Mobile', value: 'Mobile' },
        { label: 'Gaming', value: 'Gaming' },
        { label: 'Smart Home', value: 'Smart Home' }
    ];
    
    // Wire methods
    @wire(getSystemHealth)
    wiredSystemHealthMethod(result) {
        this.wiredSystemHealth = result;
        if (result.data) {
            this.systemHealth = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.systemHealth = undefined;
        }
    }
    
    @wire(getPerformanceMetrics)
    wiredPerformanceMetricsMethod(result) {
        this.wiredPerformanceMetrics = result;
        if (result.data) {
            this.performanceMetrics = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.performanceMetrics = undefined;
        }
    }
    
    @wire(getSalesAnalytics, { 
        startDate: '$startDate', 
        endDate: '$endDate', 
        groupByFields: '$groupByFields' 
    })
    wiredSalesAnalyticsMethod(result) {
        this.wiredSalesAnalytics = result;
        if (result.data) {
            this.salesAnalytics = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.salesAnalytics = undefined;
        }
    }
    
    @wire(getProductPerformanceAnalytics, { 
        timeRange: '$selectedTimeRange', 
        categoryFilter: '$selectedCategory' 
    })
    wiredProductAnalyticsMethod(result) {
        this.wiredProductAnalytics = result;
        if (result.data) {
            this.productAnalytics = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.productAnalytics = undefined;
        }
    }
    
    @wire(getInventoryAnalytics, { 
        timeRange: '$selectedTimeRange', 
        categoryFilter: '$selectedCategory' 
    })
    wiredInventoryAnalyticsMethod(result) {
        this.wiredInventoryAnalytics = result;
        if (result.data) {
            this.inventoryAnalytics = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.inventoryAnalytics = undefined;
        }
    }
    
    // Lifecycle methods
    connectedCallback() {
        this.startAutoRefresh();
    }
    
    disconnectedCallback() {
        this.stopAutoRefresh();
    }
    
    // Auto-refresh functionality
    startAutoRefresh() {
        this.refreshIntervalId = setInterval(() => {
            this.refreshData();
        }, this.refreshInterval);
    }
    
    stopAutoRefresh() {
        if (this.refreshIntervalId) {
            clearInterval(this.refreshIntervalId);
            this.refreshIntervalId = null;
        }
    }
    
    // Event handlers
    handleTimeRangeChange(event) {
        this.selectedTimeRange = event.detail.value;
        this.refreshData();
    }
    
    handleCategoryChange(event) {
        this.selectedCategory = event.detail.value;
        this.refreshData();
    }
    
    handleRefresh() {
        this.refreshData();
        this.showToast('Success', 'Dashboard refreshed successfully', 'success');
    }
    
    // Data refresh methods
    async refreshData() {
        try {
            this.isLoading = true;
            
            // Refresh all wired methods
            await Promise.all([
                refreshApex(this.wiredSystemHealth),
                refreshApex(this.wiredPerformanceMetrics),
                refreshApex(this.wiredSalesAnalytics),
                refreshApex(this.wiredProductAnalytics),
                refreshApex(this.wiredInventoryAnalytics)
            ]);
            
        } catch (error) {
            this.error = error;
            this.showToast('Error', 'Failed to refresh dashboard data', 'error');
        } finally {
            this.isLoading = false;
        }
    }
    

    
    formatCurrency(amount) {
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD'
        }).format(amount || 0);
    }
    
    formatNumber(number) {
        return new Intl.NumberFormat('en-US').format(number || 0);
    }
    
    // Getters for computed properties
    get startDate() {
        const now = new Date();
        const days = this.selectedTimeRange === '7D' ? 7 : 
                    this.selectedTimeRange === '30D' ? 30 : 
                    this.selectedTimeRange === '90D' ? 90 : 365;
        const startDate = new Date(now.getTime() - (days * 24 * 60 * 60 * 1000));
        return startDate.toISOString().split('T')[0];
    }
    
    get endDate() {
        return new Date().toISOString().split('T')[0];
    }
    
    get groupByFields() {
        return ['Category__c', 'CreatedDate'];
    }
    
    get hasData() {
        return this.systemHealth || this.performanceMetrics || this.salesAnalytics || this.productAnalytics || this.inventoryAnalytics;
    }
    
    get hasErrors() {
        return this.error;
    }
    
    get errorMessage() {
        return this.error ? this.error.message : '';
    }
}

