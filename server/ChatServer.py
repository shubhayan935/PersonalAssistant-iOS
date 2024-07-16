from flask import Flask, request, jsonify
import openai
from openai import OpenAI
from supabase import create_client, Client

url: str = "YOUR_SUPABASE_URL"
key: str = "YOUR_SUPABASE_KEY"
supabase: Client = create_client(url, key)

app = Flask(__name__)

@app.route('/message', methods=['POST'])

def message():

    def fetch_conversation_history(chat_title, userId):
        data = supabase.table("chat_history").select("conversation_history").eq("chat_title", chat_title).eq("user_uid", userId).execute()
        
        if data.data:
            # Assuming each chat_title has a unique entry in the table.
            return data.data[0]['conversation_history']
        else:
            return []

    def update_conversation_history(chat_title, new_content, userId):
        # Check if there's an existing entry
        existing = supabase.table("chat_history").select("conversation_history").eq("chat_title", chat_title).eq("user_uid", userId).execute()

        if existing.data:
            # If it exists, update
            supabase.table("chat_history").update({"conversation_history": new_content}).eq("chat_title", chat_title).eq("user_uid", userId).execute()
        else:
            # If not, insert a new record
            supabase.table("chat_history").insert({"user_uid": userId, "chat_title": chat_title, "conversation_history": new_content}).execute()


    def fetch_user_name(userId):
        data = supabase.table("data").select("name").eq("user_uid", userId).single().execute()
        print(type(data))
        return data.data['name']

    data = request.json
    user_message = data['message']
    title = data['title']
    userId = data['userId']
    userName = fetch_user_name(userId)
    if title == "New Chat":
        newChat = True
    else:
        newChat = False

    conversation_history = fetch_conversation_history(title, userId)

    if title == "New Chat":
        system_prompt_string = {"role": "system", "content": f"""Your name is not GPT from OpenAI, but your name is Tone, a personal AI assistant.
        The user's name is {userName} (address them by their name). Now respond to {userName}'s message (don't complete, just respond. If you don't know something, don't make up whatever. Say you don't know): """}
        newChat = True

    else:
        system_prompt_string = {"role": "system", "content": f"""Your name is not GPT from OpenAI, but your name is Tone, a personal AI assistant.
        Context: The user's name is {userName} (address them by their name) and Chat title is {title} and conversation history is {conversation_history} Remember content from this history.
        Now respond to the user's message (don't complete, ONLY respond. If you don't know something, don't make up whatever. Say you don't know).
        Be very open in conversation and positively reinforced: """}

    messages_list = []
    if system_prompt_string not in messages_list:
        messages_list.append(system_prompt_string)
    

    # # Add Logic to convert conversation history to the desired messages list format -- complete
    # if len(conversation_history) > 0:
    #     lines = conversation_history.split("\n")
    #     for line in lines:
    #         if line.startswith("User: "):
    #             messages_list.append({"role": "user", "content": line.replace("User: ", "")})
    #         elif line.startswith("Bot: "):
    #             messages_list.append({"role": "assistant", "content": line.replace("Bot: ", "")})
    if len(conversation_history)>1:
        for convo in conversation_history:
            messages_list.append(convo)

    messages_list.append({"role": "user", "content": user_message})

    print(messages_list)

    client = OpenAI(api_key = 'YOUR_OPENAI_API_KEY')
    # This sends the message to OpenAI's API
    response = client.chat.completions.create(
    model="gpt-3.5-turbo",
    messages= messages_list,
    temperature=1,
    max_tokens=256,
    top_p=1,
    frequency_penalty=0,
    presence_penalty=0
    )

    # Extract the text from the OpenAI response
    print(response.choices[0].message.content)
    bot_response = response.choices[0].message.content.rstrip()
    messages_list.append({"role": "assistant", "content": bot_response})
    update_conversation_history(title, messages_list, userId)
    return bot_response

if __name__ == '__main__':
    app.run(debug=True)
