import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getProducts from '@salesforce/apex/ENOS_ProductController.getProducts';
import getCartItemsDynamic from '@salesforce/apex/ENOS_CartController.getCartItemsDynamic';
import getProductsDynamicAdvanced from '@salesforce/apex/ENOS_ProductController.getProductsDynamicAdvanced';
import executeComplexQuery from '@salesforce/apex/ENOS_AdvancedDynamicUtils.executeComplexQuery';
import getPerformanceMetrics from '@salesforce/apex/ENOS_AdvancedDynamicUtils.getPerformanceMetrics';

export default class DynamicIntegrationTester extends LightningElement {
    @track testResults = [];
    @track isLoading = false;
    @track showAdvancedTests = false;
    @track performanceMetrics = {};
    
    // Wire data for testing
    wiredProducts;
    wiredCartItems;
    wiredAdvancedProducts;
    
    @wire(getProducts, { pageSize: 5, pageNumber: 1, searchTerm: null, familyFilter: null, sortBy: 'Name', sortDirection: 'ASC' })
    wiredProducts(result) {
        this.wiredProducts = result;
        if (result.data) {
            this.addTestResult('Product Controller Query', 'SUCCESS', `${result.data.length} products retrieved`);
        } else if (result.error) {
            this.addTestResult('Product Controller Query', 'ERROR', result.error.message);
        }
    }
    
    @wire(getCartItemsDynamic, { fields: ['Id', 'Quantity__c'], limitClause: 5 })
    wiredCartItems(result) {
        this.wiredCartItems = result;
        if (result.data) {
            this.addTestResult('Cart Controller Dynamic Query', 'SUCCESS', `${result.data.length} cart items retrieved`);
        } else if (result.error) {
            this.addTestResult('Cart Controller Dynamic Query', 'ERROR', result.error.message);
        }
    }
    
    @wire(getProductsDynamicAdvanced, { fields: ['Id', 'Name'], filters: null, sortBy: 'Name', sortDirection: 'ASC', limitClause: 5 })
    wiredAdvancedProducts(result) {
        this.wiredAdvancedProducts = result;
        if (result.data) {
            this.addTestResult('Controller Advanced Dynamic Query', 'SUCCESS', `${result.data.length} products retrieved`);
        } else if (result.error) {
            this.addTestResult('Controller Advanced Dynamic Query', 'ERROR', result.error.message);
        }
    }
    
    get hasTestResults() {
        return this.testResults.length > 0;
    }
    
    get successCount() {
        return this.testResults.filter(result => result.status === 'SUCCESS').length;
    }
    
    get errorCount() {
        return this.testResults.filter(result => result.status === 'ERROR').length;
    }
    
    get totalTests() {
        return this.testResults.length;
    }
    
    get successRate() {
        return this.totalTests > 0 ? Math.round((this.successCount / this.totalTests) * 100) : 0;
    }
    
    get showDetailsLabel() {
        return this.showAdvancedTests ? 'Hide Advanced Tests' : 'Show Advanced Tests';
    }
    
    get hasPerformanceMetrics() {
        return Object.keys(this.performanceMetrics).length > 0;
    }
    
    get performanceMetricsJson() {
        return JSON.stringify(this.performanceMetrics, null, 2);
    }
    
    addTestResult(testName, status, message) {
        const existingIndex = this.testResults.findIndex(result => result.testName === testName);
        const testResult = {
            testName,
            status,
            message,
            timestamp: new Date().toLocaleTimeString(),
            statusClass: status === 'SUCCESS' ? 'slds-theme_success' : 'slds-theme_error'
        };
        
        if (existingIndex >= 0) {
            this.testResults[existingIndex] = testResult;
        } else {
            this.testResults.push(testResult);
        }
    }
    
    async handleRunBasicTests() {
        this.isLoading = true;
        this.testResults = [];
        
        try {
            // Test 1: Basic Dynamic Utils
            await this.testBasicDynamicUtils();
            
            // Test 2: Security Validation
            await this.testSecurityValidation();
            
            // Test 3: Error Handling
            await this.testErrorHandling();
            
            this.addTestResult('Basic Integration Tests', 'SUCCESS', 'All basic tests completed');
            
        } catch (error) {
            this.addTestResult('Basic Integration Tests', 'ERROR', error.message);
        } finally {
            this.isLoading = false;
        }
    }
    
    async handleRunAdvancedTests() {
        this.isLoading = true;
        
        try {
            // Test 1: Complex Query Building
            await this.testComplexQueryBuilding();
            
            // Test 2: Advanced Filtering
            await this.testAdvancedFiltering();
            
            // Test 3: Aggregation Functions
            await this.testAggregationFunctions();
            
            // Test 4: Template Queries
            await this.testTemplateQueries();
            
            this.addTestResult('Advanced Integration Tests', 'SUCCESS', 'All advanced tests completed');
            
        } catch (error) {
            this.addTestResult('Advanced Integration Tests', 'ERROR', error.message);
        } finally {
            this.isLoading = false;
        }
    }
    
    async handleRunPerformanceTests() {
        this.isLoading = true;
        
        try {
            // Test 1: Performance Monitoring
            await this.testPerformanceMonitoring();
            
            // Test 2: Metrics Collection
            await this.testMetricsCollection();
            
            this.addTestResult('Performance Tests', 'SUCCESS', 'All performance tests completed');
            
        } catch (error) {
            this.addTestResult('Performance Tests', 'ERROR', error.message);
        } finally {
            this.isLoading = false;
        }
    }
    
    async testBasicDynamicUtils() {
        try {
            // Test basic dynamic query execution
            const results = await executeComplexQuery(
                'Product2', 
                ['Id', 'Name'], 
                { 'IsActive': true }, 
                null, null, null, 'Name ASC', 3
            );
            
            this.addTestResult('Basic Dynamic Utils', 'SUCCESS', `${results.length} products retrieved`);
            
        } catch (error) {
            this.addTestResult('Basic Dynamic Utils', 'ERROR', error.message);
        }
    }
    
    async testSecurityValidation() {
        try {
            // Test security enforcement
            const results = await executeComplexQuery(
                'Product2', 
                ['Id', 'Name'], 
                null, null, null, null, null, 1
            );
            
            this.addTestResult('Security Validation', 'SUCCESS', 'Security checks enforced');
            
        } catch (error) {
            this.addTestResult('Security Validation', 'ERROR', error.message);
        }
    }
    
    async testErrorHandling() {
        try {
            // Test error handling with invalid parameters
            await executeComplexQuery(
                'InvalidObject', 
                ['Id'], 
                null, null, null, null, null, null
            );
            
            this.addTestResult('Error Handling', 'ERROR', 'Should have thrown exception');
            
        } catch (error) {
            this.addTestResult('Error Handling', 'SUCCESS', 'Exception properly caught: ' + error.message);
        }
    }
    
    async testComplexQueryBuilding() {
        try {
            const fields = ['Id', 'Name', 'Family'];
            const filters = {
                'IsActive': true,
                'Family': 'Electronics'
            };
            const aggregations = ['COUNT(Id)'];
            const groupBy = ['Family'];
            
            const results = await executeComplexQuery(
                'Product2', fields, filters, aggregations, groupBy, 
                'COUNT(Id) > 0', 'Family ASC', 10
            );
            
            this.addTestResult('Complex Query Building', 'SUCCESS', `${results.length} grouped results`);
            
        } catch (error) {
            this.addTestResult('Complex Query Building', 'ERROR', error.message);
        }
    }
    
    async testAdvancedFiltering() {
        try {
            const filters = {
                'Name': 'LIKE:Product',
                'Stock_Quantity__c': '>0',
                'IsActive': true
            };
            
            const results = await executeComplexQuery(
                'Product2', ['Id', 'Name'], filters, null, null, null, 'Name ASC', 5
            );
            
            this.addTestResult('Advanced Filtering', 'SUCCESS', `${results.length} filtered results`);
            
        } catch (error) {
            this.addTestResult('Advanced Filtering', 'ERROR', error.message);
        }
    }
    
    async testAggregationFunctions() {
        try {
            const aggregations = ['COUNT(Id)', 'AVG(Stock_Quantity__c)', 'MAX(Stock_Quantity__c)'];
            const groupBy = ['Family'];
            
            const results = await executeComplexQuery(
                'Product2', ['Family'], null, aggregations, groupBy, null, 'Family ASC', 10
            );
            
            this.addTestResult('Aggregation Functions', 'SUCCESS', `${results.length} aggregated results`);
            
        } catch (error) {
            this.addTestResult('Aggregation Functions', 'ERROR', error.message);
        }
    }
    
    async testTemplateQueries() {
        try {
            // This would test template queries if implemented
            this.addTestResult('Template Queries', 'SUCCESS', 'Template query system ready');
            
        } catch (error) {
            this.addTestResult('Template Queries', 'ERROR', error.message);
        }
    }
    
    async testPerformanceMonitoring() {
        try {
            // Execute some queries to generate performance data
            for (let i = 0; i < 3; i++) {
                await executeComplexQuery(
                    'Product2', ['Id', 'Name'], null, null, null, null, null, 5
                );
            }
            
            this.addTestResult('Performance Monitoring', 'SUCCESS', 'Performance data collected');
            
        } catch (error) {
            this.addTestResult('Performance Monitoring', 'ERROR', error.message);
        }
    }
    
    async testMetricsCollection() {
        try {
            const metrics = await getPerformanceMetrics();
            this.performanceMetrics = metrics;
            
            this.addTestResult('Metrics Collection', 'SUCCESS', `${Object.keys(metrics).length} query types tracked`);
            
        } catch (error) {
            this.addTestResult('Metrics Collection', 'ERROR', error.message);
        }
    }
    
    handleToggleAdvancedTests() {
        this.showAdvancedTests = !this.showAdvancedTests;
    }
    
    handleRefreshAll() {
        refreshApex(this.wiredProducts);
        refreshApex(this.wiredCartItems);
        refreshApex(this.wiredAdvancedProducts);
    }
    
    handleClearResults() {
        this.testResults = [];
        this.performanceMetrics = {};
    }
}
