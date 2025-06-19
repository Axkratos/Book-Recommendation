import streamlit as st
import PyPDF2
import docx
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import FAISS
from config.settings import get_embeddings
from typing import Optional

class DocumentProcessor:
    def __init__(self):
        self.text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=1000,
            chunk_overlap=200,
            length_function=len
        )
    
    def extract_text_from_pdf(self, pdf_file) -> str:
        """Extract text from PDF file"""
        try:
            pdf_reader = PyPDF2.PdfReader(pdf_file)
            text = ""
            for page in pdf_reader.pages:
                text += page.extract_text()
            return text
        except Exception as e:
            st.error(f"Error reading PDF: {str(e)}")
            return ""
    
    def extract_text_from_docx(self, docx_file) -> str:
        """Extract text from DOCX file"""
        try:
            doc = docx.Document(docx_file)
            text = ""
            for paragraph in doc.paragraphs:
                text += paragraph.text + "\n"
            return text
        except Exception as e:
            st.error(f"Error reading DOCX: {str(e)}")
            return ""
    
    def extract_text_from_txt(self, txt_file) -> str:
        """Extract text from TXT file"""
        try:
            return str(txt_file.read(), "utf-8")
        except Exception as e:
            st.error(f"Error reading TXT: {str(e)}")
            return ""
    
    def process_documents(self, uploaded_files) -> Optional[FAISS]:
        """Process uploaded documents and create vector store"""
        if not uploaded_files:
            return None
        
        all_texts = []
        
        for uploaded_file in uploaded_files:
            file_extension = uploaded_file.name.split('.')[-1].lower()
            
            if file_extension == 'pdf':
                text = self.extract_text_from_pdf(uploaded_file)
            elif file_extension == 'docx':
                text = self.extract_text_from_docx(uploaded_file)
            elif file_extension == 'txt':
                text = self.extract_text_from_txt(uploaded_file)
            else:
                st.warning(f"Unsupported file type: {file_extension}")
                continue
            
            if text.strip():
                chunks = self.text_splitter.split_text(text)
                all_texts.extend(chunks)
        
        if not all_texts:
            return None
        
        try:
            embeddings = get_embeddings()
            vectorstore = FAISS.from_texts(all_texts, embeddings)
            return vectorstore
        except Exception as e:
            st.error(f"Error creating vector store: {str(e)}")
            return None
