
import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'app.lovable.f91fe8ca67cf4ae2a89679bafbb76674',
  appName: 'investverse-chat-arena',
  webDir: 'dist',
  server: {
    url: 'https://f91fe8ca-67cf-4ae2-a896-79bafbb76674.lovableproject.com?forceHideBadge=true',
    cleartext: true
  },
  ios: {
    contentInset: 'automatic'
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 2000,
      backgroundColor: '#00B900',
      showSpinner: false
    }
  }
};

export default config;
