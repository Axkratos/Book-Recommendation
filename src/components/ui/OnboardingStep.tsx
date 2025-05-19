import { ReactNode } from 'react';
import { ChevronRight, ChevronLeft } from 'lucide-react';

interface OnboardingStepProps {
  children: ReactNode;
  title: string;
  currentStep: number;
  totalSteps: number;
  onNext?: () => void;
  onBack?: () => void;
  nextDisabled?: boolean;
  nextLabel?: string;
}

const OnboardingStep = ({
  children,
  title,
  currentStep,
  totalSteps,
  onNext,
  onBack,
  nextDisabled = false,
  nextLabel = 'Continue',
}: OnboardingStepProps) => {
  return (
    <div className="max-w-2xl mx-auto px-6 py-10">
      <div className="text-center mb-8">
        <h1 className="text-3xl font-serif font-bold mb-3">{title}</h1>
        <div className="flex justify-center space-x-1">
          {Array.from({ length: totalSteps }).map((_, index) => (
            <div
              key={index}
              className={`h-1.5 rounded-full ${
                index < currentStep ? 'bg-primary-500 w-8' : 'bg-gray-200 w-6'
              } transition-all duration-300`}
            ></div>
          ))}
        </div>
      </div>
      
      <div className="bg-white rounded-lg shadow-lg p-6 mb-8">
        {children}
      </div>
      
      <div className="flex justify-between">
        {onBack ? (
          <button
            onClick={onBack}
            className="btn btn-secondary flex items-center"
          >
            <ChevronLeft className="h-4 w-4 mr-1" />
            Back
          </button>
        ) : (
          <div></div>
        )}
        
        {onNext && (
          <button
            onClick={onNext}
            disabled={nextDisabled}
            className={`btn btn-primary flex items-center ${
              nextDisabled ? 'opacity-50 cursor-not-allowed' : ''
            }`}
          >
            {nextLabel}
            <ChevronRight className="h-4 w-4 ml-1" />
          </button>
        )}
      </div>
    </div>
  );
};

export default OnboardingStep;