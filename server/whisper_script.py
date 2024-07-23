import whisper
import openai

# Load the model
model = whisper.load_model("base.en")  # You can choose another model size as needed

# The path to your WAV file
audio_path = "test1.wav"

# Perform the transcription
result = model.transcribe(audio_path)

# Print the transcription
print(result['text'])




openai.api_key = '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'

def analyze_transcript(transcript):
    example = """{
    "action_items": [
      {
        "description": "___",
        "date": "___",
        "time": "___"
      }
    ],
    "key_points": [
      "____",
      "____",
      "____",
      "____"
    ],
    "people": "___"
  }"""
    response = openai.Completion.create(
        engine="gpt-3.5-turbo-instruct",  # Or whichever is the latest and most suitable for your use case
        prompt=f"Here's the transcript (give the output strictly in json format like this '{example}'): \"{transcript}\"\n\n"
               "1. Identify any action items such as meeting schedules or reminders, including details like dates, times, and subjects.\n"
               "2. Summarize the main topics of discussion and list key points mentioned.\n"
               "3. Identify who the user is talking to, and if it isn't mentioned in the transcript, just say '___'",
        temperature=0.5,
        max_tokens=1024,
        top_p=1.0,
        frequency_penalty=0.0,
        presence_penalty=0.0
    )
    return response.choices[0].text.strip()

# Example transcript
transcript = "Hey whats up Joe, how you doing. I'm good I'm good. Yo did you see the NVIDIA stock? yeah it's boomin. Are we still meeting Thursday 6pm? Yeah for sure."

# Analyzing the transcript
analysis_result = analyze_transcript(transcript)

print("Analysis Result:")
print(analysis_result)
