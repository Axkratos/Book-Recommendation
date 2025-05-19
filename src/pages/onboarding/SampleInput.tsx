import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Upload, FileText, ArrowRight } from 'lucide-react';
import OnboardingStep from '../../components/ui/OnboardingStep';

const SampleInput = () => {
  const [inputMethod, setInputMethod] = useState<'text' | 'image' | null>(null);
  const [textInput, setTextInput] = useState('');
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  
  const navigate = useNavigate();
  
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setImageFile(file);
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  };
  
  const handleSubmit = () => {
    // In a real app, you would upload the file or send the text to your backend
    // For now, we'll just continue to the next step
    navigate('/onboarding/recommendations');
  };
  
  const handleSkip = () => {
    navigate('/onboarding/recommendations');
  };
  
  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <OnboardingStep
        title="Help us understand your taste (optional)"
        currentStep={4}
        totalSteps={4}
        onNext={handleSubmit}
        nextLabel="Continue"
        onBack={() => navigate('/onboarding/quiz')}
      >
        <p className="text-gray-600 mb-6">
          This optional step helps us fine-tune your recommendations. You can either:
        </p>
        
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
          <button
            onClick={() => setInputMethod('text')}
            className={`flex flex-col items-center p-6 border rounded-lg transition-colors ${
              inputMethod === 'text'
                ? 'bg-primary-50 border-primary-300'
                : 'bg-white border-gray-200 hover:bg-gray-50'
            }`}
          >
            <FileText className={`h-12 w-12 mb-3 ${inputMethod === 'text' ? 'text-primary-600' : 'text-gray-400'}`} />
            <h3 className="font-medium text-lg mb-2">Paste a passage</h3>
            <p className="text-sm text-gray-500 text-center">
              Share a paragraph from a book you loved
            </p>
          </button>
          
          <button
            onClick={() => setInputMethod('image')}
            className={`flex flex-col items-center p-6 border rounded-lg transition-colors ${
              inputMethod === 'image'
                ? 'bg-primary-50 border-primary-300'
                : 'bg-white border-gray-200 hover:bg-gray-50'
            }`}
          >
            <Upload className={`h-12 w-12 mb-3 ${inputMethod === 'image' ? 'text-primary-600' : 'text-gray-400'}`} />
            <h3 className="font-medium text-lg mb-2">Upload a cover</h3>
            <p className="text-sm text-gray-500 text-center">
              Share a book cover image of something you enjoyed
            </p>
          </button>
        </div>
        
        {inputMethod === 'text' && (
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Paste a paragraph from a book you loved
            </label>
            <textarea
              value={textInput}
              onChange={(e) => setTextInput(e.target.value)}
              className="w-full border border-gray-300 rounded-md px-3 py-2 h-32 focus:ring-2 focus:ring-primary-300 focus:border-primary-500 focus:outline-none"
              placeholder="Start typing or paste text here..."
            ></textarea>
          </div>
        )}
        
        {inputMethod === 'image' && (
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Upload a book cover image
            </label>
            
            <div className="mt-1 flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 border-dashed rounded-lg">
              {imagePreview ? (
                <div className="text-center">
                  <img
                    src={imagePreview}
                    alt="Book cover preview"
                    className="mx-auto h-48 object-contain mb-4"
                  />
                  <button
                    onClick={() => {
                      setImageFile(null);
                      setImagePreview(null);
                    }}
                    className="text-sm text-red-600 hover:text-red-700"
                  >
                    Remove image
                  </button>
                </div>
              ) : (
                <div className="space-y-1 text-center">
                  <Upload className="mx-auto h-12 w-12 text-gray-400" />
                  <div className="flex text-sm text-gray-600">
                    <label
                      htmlFor="file-upload"
                      className="relative cursor-pointer bg-white rounded-md font-medium text-primary-600 hover:text-primary-500 focus-within:outline-none focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-primary-500"
                    >
                      <span>Upload a file</span>
                      <input
                        id="file-upload"
                        name="file-upload"
                        type="file"
                        className="sr-only"
                        accept="image/*"
                        onChange={handleFileChange}
                      />
                    </label>
                    <p className="pl-1">or drag and drop</p>
                  </div>
                  <p className="text-xs text-gray-500">PNG, JPG, GIF up to 10MB</p>
                </div>
              )}
            </div>
          </div>
        )}
        
        <div className="text-center mt-8">
          <button
            onClick={handleSkip}
            className="text-gray-500 hover:text-gray-700 flex items-center mx-auto"
          >
            Skip this step
            <ArrowRight className="h-4 w-4 ml-1" />
          </button>
        </div>
      </OnboardingStep>
    </div>
  );
};

export default SampleInput;