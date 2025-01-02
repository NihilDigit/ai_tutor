from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
import logging
from pydantic import BaseModel
from typing import List, Optional
import sqlite3
import datetime

# 配置日志
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = FastAPI()

# 添加静态文件服务
app.mount("/static", StaticFiles(directory="static"), name="static")

# 添加请求日志中间件
@app.middleware("http")
async def log_requests(request: Request, call_next):
    logger.info(f"Request: {request.method} {request.url}")
    logger.info(f"Headers: {request.headers}")
    try:
        body = await request.json()
        logger.info(f"Body: {body}")
    except:
        pass
    
    response = await call_next(request)
    
    logger.info(f"Response status: {response.status_code}")
    return response

# 数据库连接
DATABASE = "chat.db"

def get_db():
    conn = sqlite3.connect(DATABASE)
    conn.row_factory = sqlite3.Row
    return conn

# 初始化数据库
def init_db():
    with get_db() as conn:
        conn.execute("""
        CREATE TABLE IF NOT EXISTS messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            content TEXT NOT NULL,
            sender TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            quiz_question TEXT,
            quiz_options TEXT,
            quiz_correct_answer TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """)
        conn.execute("""
        CREATE TABLE IF NOT EXISTS quizzes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question TEXT NOT NULL,
            answer TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
        """)

# 数据模型
class Quiz(BaseModel):
    question: str
    options: List[str]
    correctAnswer: str

class Message(BaseModel):
    content: str
    sender: str
    timestamp: str
    quiz: Optional[Quiz] = None

class QuizAnswer(BaseModel):
    answer: str

# API路由
@app.post("/messages")
async def send_message(message: Message):
    with get_db() as conn:
        cursor = conn.cursor()
        quiz_question = message.quiz.question if message.quiz else None
        quiz_options = ','.join(message.quiz.options) if message.quiz else None
        quiz_correct_answer = message.quiz.correctAnswer if message.quiz else None
        
        cursor.execute("""
            INSERT INTO messages (
                content, 
                sender, 
                timestamp,
                quiz_question,
                quiz_options,
                quiz_correct_answer
            ) VALUES (?, ?, ?, ?, ?, ?)
        """, (
            message.content,
            message.sender,
            message.timestamp,
            quiz_question,
            quiz_options,
            quiz_correct_answer
        ))
        conn.commit()
        return {"message": "Message sent successfully"}

@app.get("/")
async def read_root():
    return FileResponse("static/index.html")

@app.get("/messages")
async def get_messages():
    with get_db() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM messages ORDER BY created_at DESC")
        messages = []
        for row in cursor.fetchall():
            message = {
                "content": row["content"],
                "sender": row["sender"],
                "timestamp": row["timestamp"]
            }
            if row["quiz_question"]:
                message["quiz"] = {
                    "question": row["quiz_question"],
                    "options": row["quiz_options"].split(','),
                    "correctAnswer": row["quiz_correct_answer"]
                }
            messages.append(message)
        return messages

@app.post("/quizzes/{quiz_id}/answer")
async def handle_quiz_answer(quiz_id: int, answer: QuizAnswer):
    with get_db() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT answer FROM quizzes WHERE id = ?", (quiz_id,))
        quiz = cursor.fetchone()
        if not quiz:
            raise HTTPException(status_code=404, detail="Quiz not found")
        
        if quiz["answer"] == answer.answer:
            return {"result": "Correct"}
        else:
            return {"result": "Incorrect"}

@app.post("/system-messages")
async def add_system_message(message: Message):
    message.is_system = True
    return await send_message(message)

# 启动时初始化数据库
@app.on_event("startup")
async def startup():
    init_db()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
