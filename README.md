📊 Revenue Attribution Modeling Project
Objective:
To design and implement a robust, SQL-based revenue attribution system that enables multi-model channel performance analysis and dynamic reporting in Power BI.

🧠 Project Overview:
This project addresses the critical challenge of understanding how various marketing channels contribute to conversions. Using a simulated dataset of over 10,000 user journeys and conversions, we built advanced attribution models to allocate revenue accurately across user touchpoints.

🔧 Technical Implementation:
SQL Database: PostgreSQL (via pgAdmin)

Dataset:

user_journey: Contains timestamped channel interactions per user

conversions: Contains user conversions and revenue

Key SQL Techniques:

ROW_NUMBER(), LAG(), LEAD() for user timeline construction

EXTRACT(EPOCH ...), EXP() for time-decay calculations

Window functions for ranking and aggregation

Dynamic attribution model switching via parameter table

Indexing for query performance optimization

🧮 Attribution Models Implemented:
First-Touch Attribution – Revenue credited to the first channel interaction before conversion.

Last-Touch Attribution – Full credit to the final interaction.

Linear Attribution – Equal credit split across all interactions.

Time-Decay Attribution – Exponentially weighted credit favoring more recent interactions.

📈 Power BI Visualizations:
Line Chart: Daily revenue trends across models

Clustered Column Chart: Revenue by channel and model

Donut Chart: Channel share of total attributed revenue

Matrix Table: Detailed cross-model breakdown by channel

These visuals enable clear comparison of how revenue is distributed under each attribution strategy and support decision-making for marketing spend optimization.

✅ Outcomes:
Created a dynamic, scalable SQL framework for multi-model attribution.

Delivered an interactive Power BI dashboard ready for stakeholder use.

Equipped decision-makers with model-specific insights for smarter channel investments.
