import os, json, base64
from oauth2client.service_account import ServiceAccountCredentials
import gspread
from dotenv import load_dotenv

load_dotenv()

def append_to_google_sheet(name, phone, email, appointment_date):
 
    # 1) Decode Base64 JSON creds
    raw_b64 = os.getenv("GOOGLE_CREDENTIALS_BASE64")
    if not raw_b64:
        raise RuntimeError("Missing GOOGLE_CREDENTIALS_BASE64 in .env")
    try:
        json_str = base64.b64decode(raw_b64).decode("utf-8")
        creds_dict = json.loads(json_str)
        
    except Exception as e:
        print(f"ERROR decoding/parsing credentials: {e}")
        raise

    # 2) Sheet name
    sheet_name = os.getenv("GOOGLE_SHEET_NAME")
    if not sheet_name:
        raise RuntimeError("Missing GOOGLE_SHEET_NAME in .env")
    

    # 3) Authorize
    scope = [
        "https://spreadsheets.google.com/feeds",
        "https://www.googleapis.com/auth/drive"
    ]
    creds = ServiceAccountCredentials.from_json_keyfile_dict(creds_dict, scope)
    client = gspread.authorize(creds)
    

    # 4) Append
    sheet = client.open(sheet_name).sheet1
    sheet.append_row([name, phone, email, appointment_date])
    
