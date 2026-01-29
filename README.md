# Sales-Exploratory-Data-Analysis
A six step SQL unpacking of sales data:

1. Database Exploration

2. Dimensions Exploration
   WHAT? Identify the unique values in each dimension
   WHY? To recognise how data might be grouped or segmented

3. Date Exploration
   WHAT? Indentify boundaries: the earliest and latests dates
   WHY? To understand the scope of data and the timespan
   HOW? Range:
	      MIN/MAX = [Date Dimension]
      	MIN = order_date
      	MIN = Birthdate
      	MAX = create_date
      	DATEDIFF

4. Measures Exploration
   WHAT? Calculate key metrics (Big Numbers)
   WHY? Totals
   HOW? Aggregation
    
5. Magnitude
   WHAT? Compare the measure of values by categories
   WHY? Understand the categories
   HOW? Aggregation:
        AVG
	      LEFT JOIN
	      GROUP BY
	      ORDER BY

6. Ranking
   WHAT? Order values of dimensions by measure, e.g. Rank [Countries] by [Total Sales]
   WHY? Identify top and bottom performers
   HOW? Rank [DIMENSION] by [MEASURE]:
	      RANK()
	      DENSE_RANK()
	      ROW_NUMBER()
