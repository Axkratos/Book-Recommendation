import { X } from 'lucide-react';
import { notifications } from '../../data/mockData';

interface NotificationsPanelProps {
  onClose: () => void;
}

const NotificationsPanel = ({ onClose }: NotificationsPanelProps) => {
  return (
    <div className="fixed inset-0 z-50 overflow-hidden">
      <div className="absolute inset-0 bg-black/30" onClick={onClose}></div>
      
      <div className="fixed inset-y-0 right-0 max-w-sm w-full bg-white shadow-xl overflow-y-auto">
        <div className="p-4 border-b border-gray-200 flex items-center justify-between">
          <h2 className="text-lg font-medium">Notifications</h2>
          <button onClick={onClose} className="text-gray-500 hover:text-gray-700">
            <X className="h-5 w-5" />
          </button>
        </div>
        
        <div className="divide-y divide-gray-200">
          {notifications.length > 0 ? (
            notifications.map((notification) => (
              <div
                key={notification.id}
                className={`p-4 hover:bg-gray-50 ${!notification.read ? 'bg-blue-50' : ''}`}
              >
                <div className="flex items-start">
                  <div className={`flex-shrink-0 h-8 w-8 rounded-full flex items-center justify-center ${
                    notification.type === 'recommendation'
                      ? 'bg-purple-100 text-purple-500'
                      : notification.type === 'streak'
                      ? 'bg-green-100 text-green-500'
                      : notification.type === 'club'
                      ? 'bg-blue-100 text-blue-500'
                      : 'bg-orange-100 text-orange-500'
                  }`}>
                    {notification.type === 'recommendation' && '📚'}
                    {notification.type === 'streak' && '🔥'}
                    {notification.type === 'club' && '👥'}
                    {notification.type === 'companion' && '🤖'}
                  </div>
                  <div className="ml-3 flex-1">
                    <p className="text-sm text-gray-900">{notification.message}</p>
                    <p className="mt-1 text-xs text-gray-500">{notification.time}</p>
                  </div>
                </div>
              </div>
            ))
          ) : (
            <div className="p-4 text-center text-gray-500">
              No notifications yet
            </div>
          )}
        </div>
        
        <div className="p-4 border-t border-gray-200">
          <button className="w-full px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">
            Clear All
          </button>
        </div>
      </div>
    </div>
  );
};

export default NotificationsPanel;