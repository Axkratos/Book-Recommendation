import { createContext, useContext, useState, ReactNode } from 'react';
import { User, currentUser as mockUser } from '../data/mockData';

interface UserContextType {
  user: User | null;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  updatePreferences: (preferences: Partial<User['preferences']>) => void;
}

const UserContext = createContext<UserContextType | undefined>(undefined);

export const useUser = () => {
  const context = useContext(UserContext);
  if (context === undefined) {
    throw new Error('useUser must be used within a UserProvider');
  }
  return context;
};

export const UserProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);

  const login = async (email: string, password: string) => {
    // In a real app, this would make an API call
    // For now, we'll just set the mock user after a short delay
    return new Promise<void>((resolve) => {
      setTimeout(() => {
        setUser(mockUser);
        localStorage.setItem('visitedBefore', 'true');
        resolve();
      }, 800);
    });
  };

  const logout = () => {
    setUser(null);
  };

  const updatePreferences = (preferences: Partial<User['preferences']>) => {
    if (user) {
      setUser({
        ...user,
        preferences: {
          ...user.preferences,
          ...preferences,
        },
      });
    }
  };

  return (
    <UserContext.Provider
      value={{
        user,
        isAuthenticated: !!user,
        login,
        logout,
        updatePreferences,
      }}
    >
      {children}
    </UserContext.Provider>
  );
};