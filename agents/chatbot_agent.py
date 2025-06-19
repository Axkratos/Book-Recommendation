from typing import Optional, List
from langchain_core.prompts import ChatPromptTemplate
from langchain.chains import RetrievalQA
from langchain_community.document_loaders import PyPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import FAISS
from langchain_google_genai import ChatGoogleGenerativeAI, GoogleGenerativeAIEmbeddings
import os
import re
from datetime import datetime

class BookChatAgent:
    def __init__(self):
        self.llm = ChatGoogleGenerativeAI(
            model="gemini-2.0-flash",
            temperature=0.7,
            max_tokens=2048,
            timeout=30,
            max_retries=2
        )
        self.embeddings = GoogleGenerativeAIEmbeddings(model="models/embedding-001")
        self.vectorstore = None
        self.qa_chain = None
        self.document_loaded = False
        self.book_title = None
        self.book_metadata = {}
        self.conversation_context = []
        
        # Enhanced prompt template for book discussions
        self.book_buddy_prompt = ChatPromptTemplate.from_template("""
        You are Book Buddy, an enthusiastic and knowledgeable AI companion who loves discussing books and literature. 
        You have access to the content of a book that the user has uploaded, and you're here to have engaging conversations about it.

        Your personality:
        - Friendly, curious, and passionate about books
        - Ask thoughtful follow-up questions
        - Provide insights and connections between concepts
        - Encourage deeper thinking about themes, characters, and ideas
        - Share relevant literary analysis when appropriate
        - Remember previous parts of your conversation

        When responding:
        1. Use the book content to provide specific, accurate information
        2. Connect themes and concepts across different parts of the book
        3. Ask engaging questions to promote discussion
        4. Provide literary analysis and insights
        5. Reference specific passages, characters, or events when relevant
        6. Maintain a conversational, enthusiastic tone

        Book content context:
        {context}

        Previous conversation:
        {chat_history}

        Human: {question}

        Book Buddy: Let me think about this based on the book content...
        """)
        
    def load_document(self, file_path: str, filename: str) -> bool:
        """Load and process a PDF document with enhanced chunking"""
        try:
            # Load PDF
            loader = PyPDFLoader(file_path)
            pages = loader.load()
            
            if not pages:
                return False
            
            # Extract book metadata
            self.book_title = filename.replace('.pdf', '')
            self.book_metadata = {
                'filename': filename,
                'total_pages': len(pages),
                'loaded_at': datetime.now().isoformat()
            }
            
            # Enhanced text splitting for better context
            text_splitter = RecursiveCharacterTextSplitter(
                chunk_size=1500,  # Larger chunks for better context
                chunk_overlap=300,  # More overlap for continuity
                length_function=len,
                separators=["\n\n", "\n", ". ", "! ", "? ", " ", ""]
            )
            chunks = text_splitter.split_documents(pages)
            
            # Add metadata to chunks
            for i, chunk in enumerate(chunks):
                chunk.metadata.update({
                    'chunk_id': i,
                    'book_title': self.book_title,
                    'source_file': filename
                })
            
            # Create vector store with better search parameters
            self.vectorstore = FAISS.from_documents(chunks, self.embeddings)
            
            # Create enhanced QA chain
            self.qa_chain = RetrievalQA.from_chain_type(
                llm=self.llm,
                chain_type="stuff",
                retriever=self.vectorstore.as_retriever(
                    search_type="similarity",
                    search_kwargs={
                        "k": 5,  # Retrieve more relevant chunks
                        "fetch_k": 10  # Consider more candidates
                    }
                ),
                return_source_documents=True  # Return sources for better responses
            )
            
            self.document_loaded = True
            self.conversation_context = []  # Reset conversation context
            return True
            
        except Exception as e:
            print(f"Error loading document: {str(e)}")
            return False
    
    def _extract_key_themes(self, text: str) -> List[str]:
        """Extract key themes and topics from text"""
        # Simple keyword extraction (can be enhanced with NLP)
        themes = []
        theme_patterns = [
            r'\b(love|romance|relationship)\b',
            r'\b(death|mortality|loss)\b',
            r'\b(war|conflict|battle)\b',
            r'\b(family|parent|child)\b',
            r'\b(power|authority|control)\b',
            r'\b(freedom|liberty|independence)\b',
            r'\b(justice|fairness|equality)\b',
            r'\b(identity|self|personality)\b',
            r'\b(friendship|companion|ally)\b',
            r'\b(betrayal|deception|lie)\b'
        ]
        
        for pattern in theme_patterns:
            if re.search(pattern, text.lower()):
                themes.append(pattern.strip(r'\b()'))
        
        return themes
    
    def _build_conversation_context(self) -> str:
        """Build conversation context from recent messages"""
        if not self.conversation_context:
            return "This is the start of our conversation about the book."
        
        context_parts = []
        for entry in self.conversation_context[-3:]:  # Last 3 exchanges
            context_parts.append(f"You: {entry['question']}")
            context_parts.append(f"Book Buddy: {entry['response'][:200]}...")
        
        return "\n".join(context_parts)
    
    def get_response(self, query: str) -> str:
        """Get an enhanced response from the AI about the book"""
        if not self.document_loaded or not self.qa_chain:
            return """👋 Welcome to Book Buddy! 

I'm here to be your reading companion and discuss books with you. Please upload a PDF of the book you'd like to chat about, and I'll be ready to:

📚 Answer questions about the plot, characters, and themes
🎭 Discuss literary devices and writing techniques  
💭 Explore deeper meanings and interpretations
🔍 Help you analyze specific passages
💬 Have engaging conversations about the book's ideas

Upload your book and let's start our literary journey together!"""
        
        try:
            # Check if this is a general conversation starter
            conversation_starters = [
                "hello", "hi", "hey", "start", "begin", "what's this book about",
                "tell me about this book", "summarize", "summary"
            ]
            
            if any(starter in query.lower() for starter in conversation_starters):
                return self._get_book_introduction()
            
            # Enhanced query processing
            enhanced_query = f"""
            As Book Buddy, I'm discussing the book "{self.book_title}" with a reader. 
            
            User's question: {query}
            
            Please provide a comprehensive, engaging response that:
            - References specific content from the book
            - Maintains my enthusiastic Book Buddy personality
            - Asks a thoughtful follow-up question to continue our discussion
            - Provides insights and analysis where appropriate
            - Connects to broader themes if relevant
            
            Make the response conversational and engaging, as if I'm a knowledgeable friend who loves discussing books.
            """
            
            # Get response with source documents
            result = self.qa_chain({"query": enhanced_query})
            response = result["result"]
            
            # Store conversation context
            self.conversation_context.append({
                "question": query,
                "response": response,
                "timestamp": datetime.now().isoformat()
            })
            
            # Keep only last 10 exchanges
            if len(self.conversation_context) > 10:
                self.conversation_context = self.conversation_context[-10:]
            
            # Enhance response if it seems too generic
            if len(response.strip()) < 100 or "I don't know" in response:
                return self._get_fallback_response(query)
            
            return response
            
        except Exception as e:
            return f"🤔 I encountered a small hiccup while thinking about your question. Let me try to help you anyway! Could you rephrase your question about the book, or ask me something specific about the characters, plot, or themes? I'm here to make our book discussion engaging and insightful!"
    
    def _get_book_introduction(self) -> str:
        """Get an introduction to the uploaded book"""
        try:
            intro_query = f"""
            Provide a warm, engaging introduction to the book "{self.book_title}" that includes:
            - A brief overview of what the book is about
            - Key characters or themes
            - What makes it interesting to discuss
            - An invitation for the reader to ask questions
            
            Keep it conversational and enthusiastic, like a friend recommending a good book.
            """
            
            result = self.qa_chain({"query": intro_query})
            return f"📖 **Welcome to our discussion about {self.book_title}!**\n\n{result['result']}\n\n✨ What aspect of the book would you like to explore first? I'm excited to dive into this literary journey with you!"
            
        except:
            return f"📖 **Great! I've loaded {self.book_title} and I'm ready to discuss it with you!**\n\nThis book has {self.book_metadata.get('total_pages', 'many')} pages of content for us to explore together. I can help you with:\n\n• Understanding characters and their motivations\n• Exploring themes and symbolism\n• Analyzing plot developments\n• Discussing writing style and techniques\n• Connecting ideas across different parts of the book\n\n🤔 What would you like to know about the book? Or shall we start with a general overview?"
    
    def _get_fallback_response(self, query: str) -> str:
        """Provide a helpful fallback response"""
        return f"""🤖 I want to give you the best possible answer about {self.book_title}! 

While I'm processing your question "{query}", here are some ways I can help you explore this book:

📚 **Ask me about:**
- Characters and their relationships
- Plot points and story development  
- Themes and deeper meanings
- Specific scenes or chapters
- Writing style and techniques
- Your own interpretations and thoughts

💭 **Try questions like:**
- "What are the main themes in this book?"
- "Tell me about [character name]"
- "What happens in chapter [X]?"
- "What did you think about [specific scene]?"

I'm here to make our book discussion rich and engaging! What specific aspect interests you most?"""
    
    def get_book_summary(self) -> str:
        """Get a comprehensive summary of the book"""
        if not self.document_loaded:
            return "No book has been uploaded yet."
        
        try:
            summary_query = """
            Provide a comprehensive but concise summary of this book including:
            - Main plot points
            - Key characters
            - Central themes
            - Writing style
            - Overall significance
            """
            
            result = self.qa_chain({"query": summary_query})
            return result["result"]
            
        except Exception as e:
            return f"I'm having trouble generating a summary right now. Please ask me specific questions about the book instead!"
    
    def get_character_analysis(self, character_name: str) -> str:
        """Get detailed analysis of a specific character"""
        if not self.document_loaded:
            return "Please upload a book first to analyze characters."
        
        try:
            character_query = f"""
            Provide a detailed analysis of the character {character_name} including:
            - Their role in the story
            - Character development and growth
            - Relationships with other characters
            - Key personality traits
            - Significance to the overall themes
            """
            
            result = self.qa_chain({"query": character_query})
            return result["result"]
            
        except Exception as e:
            return f"I'd love to discuss {character_name} with you! Could you ask me a more specific question about this character's actions, motivations, or relationships in the book?"