import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { useState, useEffect } from 'react';
import { UserProvider } from './context/UserContext';
import { BookProvider } from './context/BookContext';
import { BookClubProvider } from './context/BookClubContext';

// Layouts
import MainLayout from './components/layout/MainLayout';

// Pages
import Home from './pages/Home';
import Signup from './pages/auth/Signup';
import OnboardingQuiz from './pages/onboarding/OnboardingQuiz';
import SampleInput from './pages/onboarding/SampleInput';
import FirstRecommendations from './pages/onboarding/FirstRecommendations';
import Dashboard from './pages/Dashboard';
import ReadingView from './pages/ReadingView';
import BookUniverseMap from './pages/BookUniverseMap';
import MyShelf from './pages/MyShelf';
import CommunityClubs from './pages/CommunityClubs';
import NotFound from './pages/NotFound';

function App() {
  const [isFirstVisit, setIsFirstVisit] = useState(true);

  useEffect(() => {
    const visitedBefore = localStorage.getItem('visitedBefore');
    if (visitedBefore) {
      setIsFirstVisit(false);
    }
  }, []);

  return (
    <Router>
      <UserProvider>
        <BookProvider>
          <BookClubProvider>
            <Routes>
              {/* Auth & Onboarding Routes */}
              <Route path="/signup" element={<Signup />} />
              <Route path="/onboarding/quiz" element={<OnboardingQuiz />} />
              <Route path="/onboarding/sample-input" element={<SampleInput />} />
              <Route path="/onboarding/recommendations" element={<FirstRecommendations />} />
              
              {/* Main App Routes */}
              <Route path="/" element={<MainLayout />}>
                <Route index element={isFirstVisit ? <Home /> : <Dashboard />} />
                <Route path="dashboard" element={<Dashboard />} />
                <Route path="reading/:bookId" element={<ReadingView />} />
                <Route path="universe-map" element={<BookUniverseMap />} />
                <Route path="my-shelf" element={<MyShelf />} />
                <Route path="community" element={<CommunityClubs />} />
                <Route path="*" element={<NotFound />} />
              </Route>
            </Routes>
          </BookClubProvider>
        </BookProvider>
      </UserProvider>
    </Router>
  );
}

export default App;