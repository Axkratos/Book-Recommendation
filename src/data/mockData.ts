export interface User {
  id: string;
  name: string;
  email: string;
  avatar: string;
  preferences: {
    genres: string[];
    authors: string[];
    mood: string;
  };
  readingStreak: number;
  joinedDate: string;
}

export interface Book {
  id: string;
  title: string;
  author: string;
  coverUrl: string;
  rating: number;
  genres: string[];
  tags: string[];
  publishYear: number;
  summary: string;
  themes: string[];
  currentChapter?: number;
  totalChapters?: number;
  progress?: number;
}

export interface BookClub {
  id: string;
  name: string;
  description: string;
  members: number;
  avatars: string[];
  currentBook: Book;
}

export interface Notification {
  id: string;
  type: 'recommendation' | 'streak' | 'club' | 'companion';
  message: string;
  time: string;
  read: boolean;
}

export interface AIMessage {
  id: string;
  sender: 'user' | 'ai';
  message: string;
  timestamp: string;
}

// Mock User Data
export const currentUser: User = {
  id: '1',
  name: 'Alice',
  email: 'alice@example.com',
  avatar: 'https://images.pexels.com/photos/415829/pexels-photo-415829.jpeg?auto=compress&cs=tinysrgb&w=150',
  preferences: {
    genres: ['Mystery', 'Science Fiction', 'Historical Fiction'],
    authors: ['N.K. Jemisin', 'Neil Gaiman', 'Kazuo Ishiguro'],
    mood: 'Adventurous',
  },
  readingStreak: 5,
  joinedDate: '2023-01-15',
};

// Mock Book Data
export const books: Book[] = [
  {
    id: '1',
    title: 'The Fifth Season',
    author: 'N.K. Jemisin',
    coverUrl: 'https://images.pexels.com/photos/1765033/pexels-photo-1765033.jpeg?auto=compress&cs=tinysrgb&w=300',
    rating: 4.7,
    genres: ['Fantasy', 'Science Fiction'],
    tags: ['apocalyptic', 'award-winning', 'character-driven'],
    publishYear: 2015,
    summary: 'This is the way the world ends... for the last time. A season of endings has begun. It starts with the great red rift across the heart of the world\'s sole continent, spewing ash that blots out the sun.',
    themes: ['Climate change', 'Oppression', 'Motherhood', 'Survival'],
    currentChapter: 5,
    totalChapters: 20,
    progress: 25,
  },
  {
    id: '2',
    title: 'Klara and the Sun',
    author: 'Kazuo Ishiguro',
    coverUrl: 'https://images.pexels.com/photos/2099691/pexels-photo-2099691.jpeg?auto=compress&cs=tinysrgb&w=300',
    rating: 4.3,
    genres: ['Science Fiction', 'Literary Fiction'],
    tags: ['philosophical', 'AI', 'near-future'],
    publishYear: 2021,
    summary: 'From the bestselling author of Never Let Me Go and The Remains of the Day, a novel about love, loneliness, and what it means to be human, seen through the eyes of an Artificial Friend.',
    themes: ['Artificial intelligence', 'Purpose', 'Humanity', 'Love'],
  },
  {
    id: '3',
    title: 'The Midnight Library',
    author: 'Matt Haig',
    coverUrl: 'https://images.pexels.com/photos/3747139/pexels-photo-3747139.jpeg?auto=compress&cs=tinysrgb&w=300',
    rating: 4.2,
    genres: ['Fiction', 'Fantasy', 'Contemporary'],
    tags: ['uplifting', 'philosophical', 'life-changing'],
    publishYear: 2020,
    summary: 'Between life and death there is a library, and within that library, the shelves go on forever. Every book provides a chance to try another life you could have lived.',
    themes: ['Regret', 'Possibilities', 'Depression', 'Hope'],
  },
  {
    id: '4',
    title: 'The Night Circus',
    author: 'Erin Morgenstern',
    coverUrl: 'https://images.pexels.com/photos/3646172/pexels-photo-3646172.jpeg?auto=compress&cs=tinysrgb&w=300',
    rating: 4.0,
    genres: ['Fantasy', 'Romance', 'Historical Fiction'],
    tags: ['magical', 'atmospheric', 'competition'],
    publishYear: 2011,
    summary: 'The circus arrives without warning. No announcements precede it. It is simply there, when yesterday it was not. Within the black-and-white striped canvas tents is an utterly unique experience full of breathtaking amazements.',
    themes: ['Love', 'Fate', 'Competition', 'Magic'],
  },
  {
    id: '5',
    title: 'Mexican Gothic',
    author: 'Silvia Moreno-Garcia',
    coverUrl: 'https://images.pexels.com/photos/1906795/pexels-photo-1906795.jpeg?auto=compress&cs=tinysrgb&w=300',
    rating: 3.9,
    genres: ['Horror', 'Historical Fiction', 'Gothic'],
    tags: ['haunted-house', 'suspenseful', 'eerie'],
    publishYear: 2020,
    summary: 'After receiving a frantic letter from her newly-wed cousin begging for someone to save her from a mysterious doom, Noemí Taboada heads to High Place, a distant house in the Mexican countryside.',
    themes: ['Colonialism', 'Family', 'Patriarchy', 'Decay'],
  },
  {
    id: '6',
    title: 'Project Hail Mary',
    author: 'Andy Weir',
    coverUrl: 'https://images.pexels.com/photos/2101820/pexels-photo-2101820.jpeg?auto=compress&cs=tinysrgb&w=300',
    rating: 4.5,
    genres: ['Science Fiction', 'Adventure'],
    tags: ['space', 'problem-solving', 'aliens'],
    publishYear: 2021,
    summary: 'Ryland Grace is the sole survivor on a desperate, last-chance mission—and if he fails, humanity and the Earth itself will perish.',
    themes: ['Survival', 'Friendship', 'Science', 'Sacrifice'],
  },
  {
    id: '7',
    title: 'The House in the Cerulean Sea',
    author: 'TJ Klune',
    coverUrl: 'https://images.pexels.com/photos/7354270/pexels-photo-7354270.jpeg?auto=compress&cs=tinysrgb&w=300',
    rating: 4.6,
    genres: ['Fantasy', 'LGBTQ+', 'Contemporary'],
    tags: ['heartwarming', 'found-family', 'magical'],
    publishYear: 2020,
    summary: 'A magical island. A dangerous task. A burning secret. Linus Baker leads a quiet, solitary life in a tiny house with a devious cat and his old records.',
    themes: ['Acceptance', 'Family', 'Prejudice', 'Love'],
  },
  {
    id: '8',
    title: 'The Silent Patient',
    author: 'Alex Michaelides',
    coverUrl: 'https://images.pexels.com/photos/4153146/pexels-photo-4153146.jpeg?auto=compress&cs=tinysrgb&w=300',
    rating: 4.1,
    genres: ['Thriller', 'Mystery', 'Psychological Fiction'],
    tags: ['twist', 'psychological', 'page-turner'],
    publishYear: 2019,
    summary: 'Alicia Berenson\'s life is seemingly perfect. A famous painter married to an in-demand fashion photographer, she lives in a grand house with big windows overlooking a park in one of London\'s most desirable areas.',
    themes: ['Silence', 'Truth', 'Therapy', 'Murder'],
  },
];

// Mock Book Club Data
export const bookClubs: BookClub[] = [
  {
    id: '1',
    name: 'Post-Apocalyptic Art Fans',
    description: 'A community for those who appreciate art and literature set in post-apocalyptic worlds',
    members: 123,
    avatars: [
      'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=50',
      'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=50',
      'https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=50',
      'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=50',
      'https://images.pexels.com/photos/1065084/pexels-photo-1065084.jpeg?auto=compress&cs=tinysrgb&w=50',
    ],
    currentBook: books[0],
  },
  {
    id: '2',
    name: 'The AI & Philosophy Reading Group',
    description: 'Exploring the intersection of artificial intelligence and philosophical questions',
    members: 87,
    avatars: [
      'https://images.pexels.com/photos/2726111/pexels-photo-2726111.jpeg?auto=compress&cs=tinysrgb&w=50',
      'https://images.pexels.com/photos/1499327/pexels-photo-1499327.jpeg?auto=compress&cs=tinysrgb&w=50',
      'https://images.pexels.com/photos/38554/girl-people-landscape-sun-38554.jpeg?auto=compress&cs=tinysrgb&w=50',
      'https://images.pexels.com/photos/1516680/pexels-photo-1516680.jpeg?auto=compress&cs=tinysrgb&w=50',
      'https://images.pexels.com/photos/1933873/pexels-photo-1933873.jpeg?auto=compress&cs=tinysrgb&w=50',
    ],
    currentBook: books[1],
  },
  {
    id: '3',
    name: 'Magical Realism Explorers',
    description: 'Diving into books where magic blends seamlessly with reality',
    members: 156,
    avatars: [
      'https://images.pexels.com/photos/2379005/pexels-photo-2379005.jpeg?auto=compress&cs=tinysrgb&w=50',
      'https://images.pexels.com/photos/2080534/pexels-photo-2080534.jpeg?auto=compress&cs=tinysrgb&w=50',
      'https://images.pexels.com/photos/1516384/pexels-photo-1516384.jpeg?auto=compress&cs=tinysrgb&w=50',
      'https://images.pexels.com/photos/5952651/pexels-photo-5952651.jpeg?auto=compress&cs=tinysrgb&w=50',
      'https://images.pexels.com/photos/1394841/pexels-photo-1394841.jpeg?auto=compress&cs=tinysrgb&w=50',
    ],
    currentBook: books[3],
  },
];

// Mock Notification Data
export const notifications: Notification[] = [
  {
    id: '1',
    type: 'recommendation',
    message: 'Your AI Companion sent a new suggestion based on your recent reads',
    time: '2 hours ago',
    read: false,
  },
  {
    id: '2',
    type: 'streak',
    message: 'Congratulations! You maintained a 5-day reading streak',
    time: 'Yesterday',
    read: true,
  },
  {
    id: '3',
    type: 'club',
    message: 'Post-Apocalyptic Art Fans club has started a new book',
    time: '2 days ago',
    read: false,
  },
  {
    id: '4',
    type: 'companion',
    message: 'Your AI Companion has added new insights about your current book',
    time: '3 days ago',
    read: true,
  },
];

// Mock AI Conversation Data
export const aiConversation: AIMessage[] = [
  {
    id: '1',
    sender: 'ai',
    message: 'Hi Alice, want a character bio for The Fifth Season?',
    timestamp: '10:30 AM',
  },
  {
    id: '2',
    sender: 'user',
    message: 'Yes, tell me about the protagonist.',
    timestamp: '10:31 AM',
  },
  {
    id: '3',
    sender: 'ai',
    message: 'Essun is a middle-aged woman and a powerful orogene (someone who can control energy, particularly in the form of seismic activity). At the start of the novel, she discovers her husband has murdered their son and kidnapped their daughter after learning they inherited her orogene abilities. This sets her on a journey to find her daughter, while the world around her begins to end with the onset of a "Fifth Season" - a catastrophic climate event.',
    timestamp: '10:32 AM',
  },
];