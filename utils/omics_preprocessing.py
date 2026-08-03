import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.feature_selection import VarianceThreshold, SelectKBest, f_classif

class OmicsDataPreprocessor:
    """
    A utility class for preprocessing multi-omics data for recurrent ischemic stroke prediction.
    Handles missing values, scaling, and initial feature selection.
    """
    
    def __init__(self, variance_threshold=0.01, k_best_features=100):
        self.scaler = StandardScaler()
        self.var_selector = VarianceThreshold(threshold=variance_threshold)
        self.k_best_selector = SelectKBest(score_func=f_classif, k=k_best_features)
        
    def fit_transform(self, X, y=None):
        """
        Fit the preprocessing steps on the training data and transform it.
        
        Parameters:
        X (pd.DataFrame or np.ndarray): The multi-omics feature matrix.
        y (pd.Series or np.ndarray): Target labels (e.g., recurrence status).
        
        Returns:
        np.ndarray: Processed and selected feature matrix.
        """
        # 1. Handle missing values (simple imputation with median for omics data)
        if isinstance(X, pd.DataFrame):
            X_filled = X.fillna(X.median()).values
        else:
            X_filled = np.nan_to_num(X, nan=np.nanmedian(X, axis=0))
            
        # 2. Scale features to have zero mean and unit variance
        X_scaled = self.scaler.fit_transform(X_filled)
        
        # 3. Remove low-variance features (e.g., unexpressed genes/proteins)
        X_var_filtered = self.var_selector.fit_transform(X_scaled)
        
        # 4. Select top K features highly correlated with recurrence (if labels provided)
        if y is not None:
            X_final = self.k_best_selector.fit_transform(X_var_filtered, y)
            return X_final
            
        return X_var_filtered

    def transform(self, X):
        """
        Transform new/test data using the fitted parameters.
        """
        if isinstance(X, pd.DataFrame):
            X_filled = X.fillna(X.median()).values
        else:
            X_filled = np.nan_to_num(X, nan=np.nanmedian(X, axis=0))
            
        X_scaled = self.scaler.transform(X_filled)
        X_var_filtered = self.var_selector.transform(X_scaled)
        
        # Check if k_best_selector was fitted
        if hasattr(self.k_best_selector, 'scores_'):
             return self.k_best_selector.transform(X_var_filtered)
             
        return X_var_filtered

# Example usage for testing
if __name__ == "__main__":
    print("OmicsDataPreprocessor module loaded successfully.")
    # Dummy data test
    # X_dummy = pd.DataFrame(np.random.rand(100, 500))
    # y_dummy = np.random.randint(0, 2, 100)
    # preprocessor = OmicsDataPreprocessor(k_best_features=50)
    # X_processed = preprocessor.fit_transform(X_dummy, y_dummy)
    # print(f"Original shape: {X_dummy.shape}, Processed shape: {X_processed.shape}")
