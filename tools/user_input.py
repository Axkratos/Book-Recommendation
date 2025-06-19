from langchain_core.tools import tool
from utils.validators import Validators

@tool
def validate_user_input_tool(field: str, value: str) -> str:
    """Validate user input for specific fields"""
    if field == "email":
        if Validators.validate_email(value):
            return "Valid email address"
        else:
            return "Invalid email format. Please enter a valid email (e.g., user@example.com)"
    
    elif field == "phone":
        if Validators.validate_phone(value):
            return "Valid phone number"
        else:
            return "Invalid phone number. Please enter a valid phone number (e.g., +977XXXXXXXXXX)"
    
    elif field == "date":
        parsed_date = Validators.parse_date_from_text(value)
        if parsed_date:
            return f"Date parsed as: {parsed_date}"
        else:
            return "Could not parse date. Please specify a date (e.g., 'next Monday', '2024-12-25', 'tomorrow')"
    
    return "Field validation not implemented for this field type"
