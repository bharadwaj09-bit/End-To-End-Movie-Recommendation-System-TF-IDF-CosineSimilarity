# End-To-End-Movie-Recommendation-System-TF-IDF-CosineSimilarity
This project builds a content-based movie recommendation system using the MovieLens dataset and Wikipedia data (2018-2019). It analyzes movie metadata (director, actors, genre) using TF-IDF and cosine similarity to suggest personalized movies based on content similarity.

Tools & Technologies

Programming Language: R
Text Analysis: TF-IDF, Cosine Similarity
Libraries: text2vec, proxy
Dataset: Movie Lens Dataset (Kaggle), augmented with Wikipedia data (2017–2019)

Dataset
The dataset used includes:
Kaggle’s Movie Lens Dataset: Metadata for 45,000 movies (up to 2017).
Wikipedia Data: Additional entries for movies released in 2017, 2018, and 2019.
These datasets were combined and cleaned to provide a robust and accurate foundation for the recommendation system.

Project Workflow

#Step 1: Data Collection

Sourced data from Kaggle (Movie Lens Dataset) and Wikipedia.
Merged historical and recent data to ensure comprehensive coverage of movies.

#Step 2: Data Preparation

Handled missing values:
Filled categorical missing data with "unknown."
Applied interpolation for numerical data.
Standardized textual data by converting all text to lowercase.
Merged datasets using movie titles and release years.

Step 3: Feature Engineering

Created a "comb" column consolidating key attributes (director names, actor names, genres, titles).
This column served as the foundation for textual similarity computations.

Step 4: Data Transformation

Applied TF-IDF vectorization to the "comb" column to convert textual data into a machine-readable format.
Built a Document-Term Matrix (DTM) to represent movie content as numerical vectors.

Step 5: Model Development

Used cosine similarity to compute similarities between movies based on their TF-IDF vectors.
Developed a function, recommend_movies, which takes a movie title as input and outputs the top similar movies.



![Image](https://github.com/user-attachments/assets/91eccf4d-d2b1-4700-be9a-f2fa67d2b0da)


![image](https://github.com/user-attachments/assets/9777272a-a86f-4ff2-a92b-e05f36ddb1a0)






Step 6: Results

Example Recommendations:
Input: Iron Man 3 ➔ Output: Captain America: Civil War, The Avengers.
Input: Avatar ➔ Output: Movies with strong visual effects and sci-fi themes.
Movie Similarity Heatmap: Demonstrated relationships between popular movies based on cosine similarity scores.


![image](https://github.com/user-attachments/assets/b9e7a5cd-5d42-4332-8b6d-1d677a0b5bf9)







Step 7: Analytical Insights

User Engagement: The system effectively recommends movies within the same cinematic universe (e.g., Marvel), increasing user satisfaction.
Director-Specific Trends: Identified shared thematic elements across movies by directors like James Cameron (Avatar and Terminator 2).
