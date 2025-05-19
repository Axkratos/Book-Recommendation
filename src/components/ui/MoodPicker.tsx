import { useState } from 'react';
import { Smile } from 'lucide-react';

const moods = [
  { emoji: '😊', name: 'Happy' },
  { emoji: '🤔', name: 'Thoughtful' },
  { emoji: '🌟', name: 'Inspired' },
  { emoji: '😌', name: 'Relaxed' },
  { emoji: '🧠', name: 'Intellectual' },
  { emoji: '🔥', name: 'Energetic' },
  { emoji: '🌧️', name: 'Melancholic' },
  { emoji: '🕵️', name: 'Mysterious' },
];

const MoodPicker = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedMood, setSelectedMood] = useState<{ emoji: string; name: string } | null>(null);

  const handleSelectMood = (mood: { emoji: string; name: string }) => {
    setSelectedMood(mood);
    setIsOpen(false);
  };

  return (
    <div className="relative">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="p-2 rounded-full hover:bg-gray-100 flex items-center"
      >
        {selectedMood ? (
          <span className="text-xl mr-1">{selectedMood.emoji}</span>
        ) : (
          <Smile className="h-6 w-6 text-gray-600 mr-1" />
        )}
        <span className="hidden sm:inline-block text-sm">
          {selectedMood ? selectedMood.name : 'Mood'}
        </span>
      </button>

      {isOpen && (
        <div className="absolute right-0 mt-2 w-56 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 z-30">
          <div className="py-2 grid grid-cols-4 gap-1">
            {moods.map((mood) => (
              <button
                key={mood.name}
                onClick={() => handleSelectMood(mood)}
                className="flex flex-col items-center justify-center p-2 hover:bg-gray-100 rounded transition-colors"
              >
                <span className="text-2xl">{mood.emoji}</span>
                <span className="text-xs mt-1">{mood.name}</span>
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export default MoodPicker;