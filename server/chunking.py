import whisper
import os
from pydub import AudioSegment
from pydub.silence import split_on_silence

def trim_silences(audio_path, min_silence_len=10000, silence_thresh=-40): #chunk every silent interval of 10s
    """
    Trims silent segments from an audio file.

    :param audio_path: Path to the input audio file.
    :param min_silence_len: Minimum length of a silence to be used for splitting. (in ms)
    :param silence_thresh: The upper bound for how quiet is silence. (in dB)
    :return: A list of AudioSegments that contain the non-silent segments.
    """
    # Load the audio file
    sound = AudioSegment.from_wav(audio_path)

    # Split on silence
    audio_chunks = split_on_silence(sound,
                                    min_silence_len=min_silence_len,
                                    silence_thresh=silence_thresh)

    # Combine the non-silent parts
    trimmed_sound = sum(audio_chunks)

    # Return the trimmed sound
    return trimmed_sound

# Use the function
audio_path = 'test.wav'
trimmed_sound = trim_silences(audio_path)

# Save the trimmed audio
audio_path_to_transcribe = audio_path + "_final.wav"
trimmed_sound.export(audio_path_to_transcribe, format="wav")

# Load the model
model = whisper.load_model("base.en")  # You can choose another model size as needed

# Perform the transcription
result = model.transcribe(audio_path_to_transcribe)

# Print the transcription
print(result["text"])
