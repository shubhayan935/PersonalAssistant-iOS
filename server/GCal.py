from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from googleapiclient.discovery import build
import os.path
import datetime

# If modifying these scopes, delete the file token.json.
SCOPES = ['https://www.googleapis.com/auth/calendar']

def authenticate_google_calendar():
    creds = None
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first time.
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file('credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.json', 'w') as token:
            token.write(creds.to_json())
    return creds

def create_event(summary, description, start_time, end_time, attendees):
    creds = authenticate_google_calendar()
    service = build('calendar', 'v3', credentials=creds)
    
    event = {
        'summary': summary,
        'description': description,
        'start': {
            'dateTime': start_time,
            'timeZone': 'America/Los_Angeles',
        },
        'end': {
            'dateTime': end_time,
            'timeZone': 'America/Los_Angeles',
        },
        'attendees': [
            {'email': attendees},
        ],
    }
    
    event = service.events().insert(calendarId='primary', body=event).execute()
    print('Event created: %s' % (event.get('htmlLink')))

# Example usage based on your JSON output
if __name__ == '__main__':
    meeting_info = {
        "description": "Catch up",
        "date": "Monday",
        "time": "3pm"
    }
    key_points = [
        "Meeting to catch up",
        "Friday at 6pm not possible",
        "Monday at 3pm instead",
        "See you then"
    ]
    people = "Jerry"  # Assuming Jerry's email

    # Convert meeting date and time to RFC3339 format
    # Note: This example assumes the date is the next Monday from now. You might need to adjust it.
    today = datetime.date.today()
    monday = today + datetime.timedelta((0-today.weekday()) % 7)
    start_time = datetime.datetime.combine(monday, datetime.time(15, 0)).isoformat()
    end_time = datetime.datetime.combine(monday, datetime.time(16, 0)).isoformat()

    create_event(meeting_info['description'], "\n".join(key_points), start_time, end_time, people)
