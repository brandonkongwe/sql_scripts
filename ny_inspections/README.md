# NYC Restaurant Inspection Data Analysis

A SQL-based analysis of New York City restaurant inspection data to uncover food safety trends, identify risk patterns, and provide actionable insights for public health officials, restaurant owners, and policy makers.

## Dataset Overview

This project analyzes the **DOHMH New York City Restaurant Inspection Results** dataset, which contains detailed inspection records for restaurants across all five NYC boroughs. The dataset includes:

- **280,000+** inspection records
- **30,000+** unique restaurants  
- **26 columns** including restaurant details, inspection dates, violation codes, scores, and grades
- **Historical data** spanning multiple years (2015-present)

**Data Source**: [NYC Open Data Portal](https://data.cityofnewyork.us/Health/DOHMH-New-York-City-Restaurant-Inspection-Results/43nn-pn8j)

## Project Objectives

### Primary Goals
1. **Data Quality Enhancement**: Clean and standardize raw inspection data
2. **Trend Analysis**: Identify patterns in restaurant performance over time
3. **Risk Assessment**: Identify restaurants with very high closure risk
4. **Geographic Insights**: Map food safety performance across NYC neighborhoods
5. **Business Intelligence**: Provide benchmarking tools for restaurant owners

### Key Questions Addressed
- Which NYC boroughs maintain the highest food safety standards?
- Are restaurant grades improving or declining over time?
- Which cuisine types are most prone to food safety violations?
- Can we predict which restaurants are at risk of closure?
- How do seasonal patterns affect restaurant performance?

### Assumptions & Limitations
- **Data Completeness**: Analysis assumes inspection frequency is consistent across boroughs
- **Temporal Bias**: Recent data may be over-represented due to increased inspection frequency
- **Seasonal Adjustment**: Holiday and summer patterns may skew annual comparisons
- **Economic Factors**: Analysis doesn't account for external economic pressures on restaurants
