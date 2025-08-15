import { LightningElement, track, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import ENOS_PERFORMANCE_CHANNEL from '@salesforce/messageChannel/ENOS_Performance_Channel__c';

import getSystemHealth from '@salesforce/apex/ENOS_PerformanceMonitor.getSystemHealth';
import getPerformanceMetrics from '@salesforce/apex/ENOS_AdvancedDynamicUtils.getPerformanceMetrics';
import getSalesAnalytics from '@salesforce/apex/ENOS_AdvancedAnalyticsService.getSalesAnalytics';
import getProductPerformanceAnalytics from '@salesforce/apex/ENOS_AdvancedAnalyticsService.getProductPerformanceAnalytics';
import getInventoryAnalytics from '@salesforce/apex/ENOS_AdvancedAnalyticsService.getInventoryAnalytics';

export default class PerformanceDashboard extends LightningElement {
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
    subscription = null;
    
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
    
    @wire(getInventoryAnalytics)
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
    
    // Computed properties
    get startDate() {
        const endDate = new Date();
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - 30);
        return startDate.toISOString();
    }
    
    get endDate() {
        return new Date().toISOString();
    }
    
    get groupByFields() {
        return ['AccountId', 'Status'];
    }
    
    get systemStatusClass() {
        if (!this.systemHealth) return 'slds-text-color_default';
        
        switch (this.systemHealth.overallStatus) {
            case 'OK':
                return 'slds-text-color_success';
            case 'WARNING':
                return 'slds-text-color_warning';
            case 'CRITICAL':
                return 'slds-text-color_error';
            default:
                return 'slds-text-color_default';
        }
    }
    
    get systemStatusIcon() {
        if (!this.systemHealth) return 'utility:info';
        
        switch (this.systemHealth.overallStatus) {
            case 'OK':
                return 'utility:success';
            case 'WARNING':
                return 'utility:warning';
            case 'CRITICAL':
                return 'utility:error';
            default:
                return 'utility:info';
        }
    }
    
    get performanceMetricsList() {
        if (!this.performanceMetrics) return [];
        
        return Object.keys(this.performanceMetrics).map(key => ({
            name: key,
            ...this.performanceMetrics[key]
        }));
    }
    
    get salesMetrics() {
        if (!this.salesAnalytics || !this.salesAnalytics.summary) return {};
        
        return {
            totalOrders: this.salesAnalytics.summary.totalOrders || 0,
            totalRevenue: this.salesAnalytics.summary.totalRevenue || 0,
            averageOrderValue: this.salesAnalytics.summary.averageOrderValue || 0,
            uniqueCustomers: this.salesAnalytics.summary.uniqueCustomers || 0
        };
    }
    
    get topProducts() {
        if (!this.productAnalytics || !this.productAnalytics.topPerformers) return [];
        return this.productAnalytics.topPerformers.slice(0, 5);
    }
    
    get inventoryAlerts() {
        if (!this.inventoryAnalytics || !this.inventoryAnalytics.stockAlerts) return [];
        return this.inventoryAnalytics.stockAlerts.slice(0, 3);
    }
    
    // Lifecycle hooks
    connectedCallback() {
        this.subscribeToPerformanceChannel();
        this.startAutoRefresh();
    }
    
    disconnectedCallback() {
        this.unsubscribeFromPerformanceChannel();
        this.stopAutoRefresh();
    }
    
    // Message Service subscription
    @wire(MessageContext)
    messageContext;
    
    subscribeToPerformanceChannel() {
        if (this.messageContext) {
            this.subscription = subscribe(
                this.messageContext,
                ENOS_PERFORMANCE_CHANNEL,
                (message) => this.handlePerformanceMessage(message)
            );
        }
    }
    
    unsubscribeFromPerformanceChannel() {
        if (this.subscription) {
            unsubscribe(this.subscription);
            this.subscription = null;
        }
    }
    
    handlePerformanceMessage(message) {
        // Handle real-time performance updates
        if (message.type === 'PERFORMANCE_ALERT') {
            this.showToast('Performance Alert', message.message, 'warning');
            this.refreshData();
        }
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
    
    // Utility methods
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
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
    
    formatPercentage(value) {
        return `${((value || 0) * 100).toFixed(1)}%`;
    }
}

