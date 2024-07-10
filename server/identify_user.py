import numpy as np
import scipy.io.wavfile as wav
from python_speech_features import mfcc
from fastdtw import fastdtw
from scipy.spatial.distance import euclidean

def extract_features(audio_file):
    """
    Extract MFCC features from an audio file.
    """
    rate, signal = wav.read(audio_file)
    mfcc_features = mfcc(signal, rate, winlen=0.025, winstep=0.01, numcep=13, nfft=2048)
    return mfcc_features

def create_user_voiceprint(audio_files):
    """
    Create a voiceprint from a list of audio files where the user speaks certain phrases.
    """
    mfcc_features = [extract_features(audio_file) for audio_file in audio_files]
    # Combine all features into a single array
    voiceprint = np.concatenate(mfcc_features, axis=0)
    return voiceprint

def compare_features_dtw(features1, features2):
    """
    Compare two sets of MFCC features using DTW.
    Each set of features is a 2D array where rows are time steps and columns are MFCC coefficients.
    """
    distance, _ = fastdtw(features1, features2, dist=lambda x, y: np.linalg.norm(x - y, ord=1))
    return distance

def identify_user_in_audio(audio_file, user_voiceprint):
    """
    Identify if the registered user is speaking in an audio file by comparing audio features to the user's voiceprint.
    """
    # Extract features from the new audio
    segment_features = extract_features(audio_file)
    
    # Compare the audio features to the user's voiceprint
    distance = compare_features_dtw(segment_features, user_voiceprint)

    # Threshold to decide if the user is identified
    threshold = 100000  # This threshold needs tuning based on your data and voiceprint
    print(distance)
    if distance < threshold:
        print("User identified in the audio.")
    else:
        print("User not identified in the audio.")
    return distance

# Example usage:

# Create the user's voiceprint
user_voiceprint = create_user_voiceprint(['test.wav'])

# Attempt to identify the user in a new audio file
identify_user_in_audio('test.wav', user_voiceprint)
