# Steganography Enhanced Prediction Error Expansion: A Novel Reversible Data Hiding Framework

## Research Overview
X. Li, X. Li, S. Hu and Y. Zhao, "Steganography-Enhanced Prediction-Error Expansion: A Novel Reversible Data Hiding Framework," in IEEE Transactions on Circuits and Systems for Video Technology, vol. 35, no. 3, pp. 2701-2711, March 2025, doi: [10.1109/TCSVT.2024.3495673](https://doi.org/10.1109/TCSVT.2024.3495673).



## File Structure

- **main.m**: The main function that orchestrates the complete reversible data hiding process. This script integrates all the necessary components to execute the embedding and extraction procedures seamlessly.
- **embedding_example.m**: An illustrative script that walks through the embedding process with predefined parameters. This example serves as a practical guide for users to understand how to utilize the framework effectively.
- **Manner.m**: Implements the proposed embedding algorithm for the first-layer embedding. This module is crucial for initiating the reversible data hiding process with precision.
- **MEandReconsInfoGen.m**: Responsible for generating the embedding sequence and reconstruction information. This script ensures that the necessary data for both embedding and subsequent extraction is accurately prepared.
- **MHM2015.m**: An optional embedding algorithm for the second-layer embedding. This module provides an alternative approach for users who wish to explore different embedding strategies.
- **LocationMap.m**: A utility tool for calculating the location map. This script aids in identifying the optimal positions for embedding data within the cover image.
- **Arith07.m**: Implements arithmetic coding, a key component for efficient data compression and embedding.
- **stc_embed.mexw64**: The STC embedding function optimized for Windows 64-bit systems. This precompiled function enhances the performance of the embedding process on compatible platforms.
- **stc_extract.mexw64**: The STC extraction function optimized for Windows 64-bit systems. This precompiled function ensures efficient data extraction while maintaining compatibility with the embedding process.

## Getting Started

### Prerequisites
To run the code in this repository, you will need:
- MATLAB installed on your system.
- Compatibility with Windows 64-bit for the precompiled STC functions.

