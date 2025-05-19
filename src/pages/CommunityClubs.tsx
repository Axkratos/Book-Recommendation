import { useState } from 'react';
import { Users, UserPlus, MessageSquare, Search, UserMinus } from 'lucide-react';
import { useBookClubs } from '../context/BookClubContext';
import ClubChat from '../components/club/ClubChat';

const CommunityClubs = () => {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedClub, setSelectedClub] = useState<string | null>(null);
  const { clubs, joinClub, leaveClub, isClubMember } = useBookClubs();
  
  const filteredClubs = searchQuery
    ? clubs.filter(club => 
        club.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        club.description.toLowerCase().includes(searchQuery.toLowerCase())
      )
    : clubs;

  const handleJoinLeave = (clubId: string) => {
    if (isClubMember(clubId)) {
      leaveClub(clubId);
    } else {
      joinClub(clubId);
    }
  };
  
  return (
    <div className="fadeIn max-w-7xl mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-2xl font-serif font-bold mb-4">Community Book Clubs</h1>
        <p className="text-gray-600 mb-6">
          Join discussions with fellow readers who share your literary interests.
        </p>
        
        <div className="relative max-w-lg">
          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
            <Search className="h-5 w-5 text-gray-400" />
          </div>
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-primary-500 focus:border-primary-500"
            placeholder="Search book clubs..."
          />
        </div>
      </div>
      
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="space-y-6">
          {filteredClubs.map((club) => (
            <div key={club.id} className="bg-white rounded-lg shadow-md overflow-hidden">
              <div className="p-6">
                <div className="flex justify-between items-start">
                  <h2 className="text-xl font-medium">{club.name}</h2>
                  <div className="bg-primary-100 text-primary-800 text-xs font-medium px-2 py-1 rounded-full">
                    <span>{club.members} members</span>
                  </div>
                </div>
                
                <p className="mt-2 text-gray-600 text-sm">{club.description}</p>
                
                <div className="mt-4">
                  <div className="flex -space-x-2 overflow-hidden">
                    {club.avatars.map((avatar, index) => (
                      <img
                        key={index}
                        className="inline-block h-8 w-8 rounded-full ring-2 ring-white"
                        src={avatar}
                        alt="Club member"
                      />
                    ))}
                    <span className="flex items-center justify-center h-8 w-8 rounded-full bg-gray-200 ring-2 ring-white text-xs font-medium text-gray-500">
                      +{club.members - club.avatars.length}
                    </span>
                  </div>
                </div>
                
                <div className="mt-6">
                  <h3 className="text-sm font-medium text-gray-700 mb-2">Currently Reading</h3>
                  <div className="flex items-start">
                    <div className="flex-shrink-0 h-16 w-12 bg-gray-200 rounded overflow-hidden">
                      <img
                        src={club.currentBook.coverUrl}
                        alt={club.currentBook.title}
                        className="h-full w-full object-cover"
                      />
                    </div>
                    <div className="ml-3">
                      <p className="text-sm font-medium">{club.currentBook.title}</p>
                      <p className="text-xs text-gray-500">{club.currentBook.author}</p>
                    </div>
                  </div>
                </div>
                
                <div className="mt-6 flex space-x-3">
                  <button
                    onClick={() => setSelectedClub(club.id)}
                    className="btn-primary flex-1 flex items-center justify-center"
                  >
                    <MessageSquare className="h-4 w-4 mr-2" />
                    Open Chat
                  </button>
                  <button
                    onClick={() => handleJoinLeave(club.id)}
                    className={`btn flex items-center justify-center px-4 ${
                      isClubMember(club.id)
                        ? 'btn-secondary'
                        : 'btn-primary'
                    }`}
                  >
                    {isClubMember(club.id) ? (
                      <UserMinus className="h-4 w-4" />
                    ) : (
                      <UserPlus className="h-4 w-4" />
                    )}
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        <div className="lg:sticky lg:top-20">
          {selectedClub ? (
            <ClubChat clubId={selectedClub} />
          ) : (
            <div className="bg-primary-50 rounded-lg p-6 border border-primary-200">
              <div className="flex items-start">
                <div className="flex-shrink-0">
                  <Users className="h-8 w-8 text-primary-600" />
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-primary-900">Create Your Own Book Club</h3>
                  <p className="mt-1 text-primary-700">
                    Have a unique reading interest? Start your own club and connect with like-minded readers around the world.
                  </p>
                  <button className="mt-4 btn-primary">
                    Create a Club
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default CommunityClubs;