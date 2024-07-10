import whisper
import openai
import json


audio_path = "test1.wav"

# Load the model
model = whisper.load_model("base.en")  # You can choose another model size as needed

# Perform the transcription
result = model.transcribe(audio_path)

# Print the transcription
print(result)

openai.api_key = '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'

def analyze_transcript(transcript):
    example = """{
    "action_items": [
      {
        "action_item_type": "Meeting or Reminder (select only one)",
        "description": "___",
        "date": "___",
        "time": "___",
        "people": "___"
      }
    ],
    "key_points": [
      "____",
      "____",
      "____"
    ]
  }"""
    response = openai.Completion.create(
        engine="gpt-3.5-turbo-instruct",  # Or whichever is the latest and most suitable for your use case
        prompt=f"Here's the transcript (give the output STRICTLY in json format like this '{example}'): \"{transcript}\"\n\n"
        
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
transcript = result['text']

# Analyzing the transcript
analysis_result = analyze_transcript(transcript)

# Convert the string to a JSON object
json_data = json.loads(analysis_result)

print(json_data)

jsonb_supabase = json.dumps(json_data)

# Now `json_data` is a dictionary containing the JSON data
print(jsonb_supabase)
