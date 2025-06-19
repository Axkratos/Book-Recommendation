import re
from datetime import datetime, timedelta
from typing import Optional

class Validators:
    @staticmethod
    def validate_email(email: str) -> bool:
        """Validate email format"""
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        return re.match(pattern, email) is not None
    
    @staticmethod
    def validate_phone(phone: str) -> bool:
        """
        Validate Nepali mobile numbers. Accepts:
          • +9779XXXXXXXXX   (country code)
          • 9XXXXXXXXX       (local, 10 digits)
          • 09XXXXXXXXX      (local with leading zero)
        Where X is any digit, and the second digit is 6, 7, or 8.
        """
        # Strip out everything except digits and plus
        clean = re.sub(r"[^\d+]", "", phone)

        patterns = [
            r"^\+9779[6-8]\d{8}$",  # +9779XXXXXXXXX
            r"^9[6-8]\d{8}$",       # 9XXXXXXXXX
            r"^09[6-8]\d{8}$",      # 09XXXXXXXXX
        ]
        return any(re.match(p, clean) for p in patterns)
    
    @staticmethod
    def parse_date_from_text(text: str) -> Optional[str]:
        """Parse date from natural language text"""
        text = text.lower().strip()
        today = datetime.now()
        
        # Handle specific phrases
        if 'today' in text:
            return today.strftime('%Y-%m-%d')
        elif 'tomorrow' in text:
            return (today + timedelta(days=1)).strftime('%Y-%m-%d')
        elif 'next monday' in text:
            days_ahead = 0 - today.weekday()  # Monday is 0
            if days_ahead <= 0:  # Target day already happened this week
                days_ahead += 7
            return (today + timedelta(days=days_ahead)).strftime('%Y-%m-%d')
        elif 'next tuesday' in text:
            days_ahead = 1 - today.weekday()
            if days_ahead <= 0:
                days_ahead += 7
            return (today + timedelta(days=days_ahead)).strftime('%Y-%m-%d')
        elif 'next wednesday' in text:
            days_ahead = 2 - today.weekday()
            if days_ahead <= 0:
                days_ahead += 7
            return (today + timedelta(days=days_ahead)).strftime('%Y-%m-%d')
        elif 'next thursday' in text:
            days_ahead = 3 - today.weekday()
            if days_ahead <= 0:
                days_ahead += 7
            return (today + timedelta(days=days_ahead)).strftime('%Y-%m-%d')
        elif 'next friday' in text:
            days_ahead = 4 - today.weekday()
            if days_ahead <= 0:
                days_ahead += 7
            return (today + timedelta(days=days_ahead)).strftime('%Y-%m-%d')
        
        # Handle "26th may", "may 26", etc.
        month_day_patterns = [
            r'(\d{1,2})(?:st|nd|rd|th)?\s+(\w+)',  # "26th may"
            r'(\w+)\s+(\d{1,2})(?:st|nd|rd|th)?',  # "may 26th"
        ]
        
        months = {
            'january': 1, 'jan': 1, 'february': 2, 'feb': 2, 'march': 3, 'mar': 3,
            'april': 4, 'apr': 4, 'may': 5, 'june': 6, 'jun': 6,
            'july': 7, 'jul': 7, 'august': 8, 'aug': 8, 'september': 9, 'sep': 9,
            'october': 10, 'oct': 10, 'november': 11, 'nov': 11, 'december': 12, 'dec': 12
        }
        
        for pattern in month_day_patterns:
            match = re.search(pattern, text)
            if match:
                part1, part2 = match.groups()
                
                # Check which part is the month and which is the day
                if part1.lower() in months:
                    month = months[part1.lower()]
                    try:
                        day = int(part2)
                    except ValueError:
                        continue
                elif part2.lower() in months:
                    month = months[part2.lower()]
                    try:
                        day = int(part1)
                    except ValueError:
                        continue
                else:
                    continue
                
                # Use current year, but if the date has passed, use next year
                year = today.year
                try:
                    target_date = datetime(year, month, day)
                    if target_date < today:
                        year += 1
                        target_date = datetime(year, month, day)
                    return target_date.strftime('%Y-%m-%d')
                except ValueError:
                    continue
        
        # Try to parse YYYY-MM-DD format
        date_pattern = r'(\d{4}-\d{2}-\d{2})'
        match = re.search(date_pattern, text)
        if match:
            try:
                datetime.strptime(match.group(1), '%Y-%m-%d')
                return match.group(1)
            except ValueError:
                pass
        
        return None
