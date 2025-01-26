final_df = read.csv("dfmovies.csv")
library(text2vec)
library(proxy)
library(text2vec)
library(proxy)

tokens <- space_tokenizer(final_df$comb)
it <- itoken(tokens, progressbar = FALSE)
vocab <- create_vocabulary(it)
vectorizer <- vocab_vectorizer(vocab)

dtm <- create_dtm(it, vectorizer)

# Vectorization
tfidf_model <- TfIdf$new()
dtm_tfidf <- tfidf_model$fit_transform(dtm)
dtm_tfidf <- as.matrix(dtm_tfidf)

# Calculate cosine similarity
similarity_matrix <- proxy::simil(dtm_tfidf, method = "cosine")

# Function to convert the simil object to a square matrix
convert_simil_to_matrix <- function(simil_obj) {
  n <- attr(simil_obj, "Size")
  sim_matrix <- matrix(0, n, n)  # Create an n x n matrix filled with 0s
  sim_matrix[lower.tri(sim_matrix)] <- simil_obj  # Fill the lower triangle
  sim_matrix <- sim_matrix + t(sim_matrix)  # Make the matrix symmetric
  diag(sim_matrix) <- 1  # Set the diagonal to 1 (maximum similarity with itself)
  return(sim_matrix)
}

# Convert the simil object to a full square similarity matrix
similarity_matrix_full <- convert_simil_to_matrix(similarity_matrix)

recommend_movies <- function(movie_title, similarity_matrix, movie_titles, k=5) {
  movie_index <- which(movie_titles == movie_title)
  similarity_scores <- similarity_matrix[movie_index, ]
  top_indices <- order(similarity_scores, decreasing = TRUE)[1:k + 1]
  recommended_movie_titles <- movie_titles[top_indices[-1]]  # Exclude the movie itself
  return(recommended_movie_titles)
}

# Example usage
recommended_movies <- recommend_movies("iron man 3", similarity_matrix_full, final_df$movie_title)
print(recommended_movies)

# Define a vector of movie titles to get recommendations for
example_movies <- c("iron man 3", "the avengers", "avatar") # Add more titles as needed

# Function to print top recommendations for each movie
print_top_recommendations <- function(movie_titles, n=5) {
  for (movie_title in movie_titles) {
    recommendations <- recommend_movies(movie_title, similarity_matrix_full, final_df$movie_title, k=n)
    cat("Top", n, "recommendations for", movie_title, ":\n")
    print(recommendations)
    cat("\n")
  }
}

# Print top recommendations for the example movies
print_top_recommendations(example_movies)

# Assuming similarity_matrix_full is your full similarity matrix and final_df contains your movie titles

# Select a subset of movies for visualization
subset_indices <- 1:10 # Adjust this to include the indices of movies you want to visualize
subset_matrix <- similarity_matrix_full[subset_indices, subset_indices]
movie_titles_subset <- final_df$movie_title[subset_indices]

# Load necessary library
library(ggplot2)
library(reshape2)
library(stringr)

subset_matrix_df <- as.data.frame(subset_matrix, row.names = movie_titles_subset)
subset_matrix_df$Movie1 <- rownames(subset_matrix_df)

subset_matrix_long <- melt(subset_matrix_df, id.vars = "Movie1")

names(subset_matrix_long) <- c("Movie1", "Movie2", "SimilarityScore")

# Create the heatmap
ggplot(subset_matrix_long, aes(x = Movie1, y = Movie2, fill = SimilarityScore)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "red") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(x = NULL, y = NULL, fill = "Similarity\nScore", title = "Movie Similarity Heatmap") +
  scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
  scale_y_discrete(labels = function(x) str_wrap(x, width = 10)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# First, identify the indices for the specific movies
selected_movies <- c("iron man 3", "the avengers", "spider-man: far from home", "terminator 2: judgment day", "avatar")

# Use these movie titles to extract their indices from the dataset
selected_indices <- match(selected_movies, final_df$movie_title)

# Use the selected indices to create a subset similarity matrix
subset_matrix <- similarity_matrix_full[selected_indices, selected_indices]

# Convert the subset of the similarity matrix into a data frame
subset_matrix_df <- as.data.frame(subset_matrix)
rownames(subset_matrix_df) <- selected_movies
subset_matrix_df$Movie1 <- rownames(subset_matrix_df)

# Melt the subset matrix into a long format for plotting
subset_matrix_long <- melt(subset_matrix_df, id.vars = "Movie1")

# Now you can plot the heatmap using ggplot2
ggplot(subset_matrix_long, aes(x = variable, y = Movie1, fill = value)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "red") +
  labs(x = "Movies", y = "Movies", fill = "Similarity Score", title = "Movie Similarity Heatmap") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
        axis.text.y = element_text(angle = 45, hjust = 1, vjust = 1))

calculate_intra_list_similarity <- function(recommended_movies, similarity_matrix) {
  # Filter out any movies not in the similarity matrix's row names
  valid_movies <- recommended_movies[recommended_movies %in% rownames(similarity_matrix)]
  
  # Generate all unique pairs of movies from the valid recommended list
  if(length(valid_movies) >= 2) {
    movie_pairs <- t(combn(valid_movies, 2))
  } else {
    warning("Not enough valid movies for comparison. Need at least two.")
    return(NA)
  }
  
  # Calculate the similarity score for each pair
  pair_similarity_scores <- apply(movie_pairs, 1, function(pair) {
    index1 <- match(pair[1], rownames(similarity_matrix))
    index2 <- match(pair[2], colnames(similarity_matrix))
    # Extract and return the similarity score
    score <- similarity_matrix[index1, index2]
    if(!is.numeric(score)) {
      warning(paste("Non-numeric score found for pair:", pair[1], "-", pair[2]))
    }
    return(score)
  })
  
  # Debug: Check the type of pair_similarity_scores
  print(str(pair_similarity_scores))
  
  # Compute and return the average similarity score, excluding any NA values
  mean_similarity <- mean(as.numeric(pair_similarity_scores), na.rm = TRUE)
  
  if(is.na(mean_similarity)) {
    warning("NA returned for mean similarity, check for non-numeric values.")
  }
  
  return(mean_similarity)
}

# Attempt to recalculate the intra-list similarity
intra_list_similarity <- calculate_intra_list_similarity(recommended_list, similarity_matrix_full)
print(intra_list_similarity)
