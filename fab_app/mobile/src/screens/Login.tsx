import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  KeyboardAvoidingView,
  Platform,
  StyleSheet,
  ActivityIndicator
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import PressableScale from '../components/PressableScale';
import { login, setAuthToken } from '../services/api';
import { Feather } from '@expo/vector-icons';

export default function Login({ navigation }: any) {
  const [adminId, setAdminId] = useState('');
  const [accessCode, setAccessCode] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showPassword, setShowPassword] = useState(false);

  const handleLogin = async () => {
    if (!adminId || !accessCode) {
      setError('Please fill in both fields');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const response = await login({
        username: adminId,
        password: accessCode
      });
      
      const token = response.access_token;
      setAuthToken(token);
      
      navigation.navigate('Main');
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Invalid credentials');
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardView}
      >
        <View style={styles.headerContainer}>
          <View style={styles.nameplate}>
            <Text style={styles.nameplateText}>Fabrication Tool{'\n'}& Machine Management</Text>
          </View>
        </View>

        <View style={styles.formPanel}>
          <Text style={styles.formLabel}>Sign in</Text>

          {error && (
            <View style={styles.errorBanner}>
              <Text style={styles.errorText}>{error}</Text>
            </View>
          )}

          <TextInput
            style={styles.input}
            placeholder="Admin ID"
            placeholderTextColor="#8C7F72"
            value={adminId}
            onChangeText={setAdminId}
            autoCapitalize="none"
          />

          <View style={styles.passwordContainer}>
            <TextInput
              style={styles.passwordInput}
              placeholder="Password"
              placeholderTextColor="#8C7F72"
              value={accessCode}
              onChangeText={setAccessCode}
              secureTextEntry={!showPassword}
            />
            <PressableScale onPress={() => setShowPassword(!showPassword)} style={styles.eyeIcon}>
              <Feather name={showPassword ? "eye" : "eye-off"} size={20} color="#8C7F72" />
            </PressableScale>
          </View>

          <PressableScale
            style={styles.button}
            onPress={handleLogin}
            disabled={loading}
          >
            {loading ? (
              <ActivityIndicator color="#C25B6E" />
            ) : (
              <Text style={styles.buttonText}>Enter System</Text>
            )}
          </PressableScale>

          <PressableScale 
            style={styles.linkButton} 
            onPress={() => navigation.navigate('Register')}
          >
            <Text style={styles.linkText}>Create an account</Text>
          </PressableScale>
        </View>

        <View style={styles.footerContainer}>
          <Text style={styles.statusText}>System status: Ready</Text>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F7F0E7',
  },
  keyboardView: {
    flex: 1,
    justifyContent: 'space-between',
    paddingHorizontal: 24,
    paddingVertical: 32,
  },
  headerContainer: {
    alignItems: 'center',
    marginTop: 20,
  },
  nameplate: {
    borderWidth: 1,
    borderColor: '#EDE1D3',
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 14,
  },
  nameplateText: {
    fontFamily: 'Inter_700Bold',
    color: '#3A322B',
    fontSize: 20,
    textAlign: 'center',
  },
  formPanel: {
    backgroundColor: '#FFFCF8',
    padding: 24,
    borderWidth: 1,
    borderColor: '#EDE1D3',
    borderRadius: 14,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.08,
    shadowRadius: 5,
    elevation: 8,
  },
  formLabel: {
    fontFamily: 'Inter_700Bold',
    color: '#3A322B',
    fontSize: 18,
    marginBottom: 20,
  },
  input: {
    backgroundColor: '#F7F0E7',
    borderWidth: 1,
    borderColor: '#EDE1D3',
    color: '#3A322B',
    fontFamily: 'Inter_400Regular',
    fontSize: 16,
    paddingHorizontal: 16,
    paddingVertical: 12,
    marginBottom: 16,
    borderRadius: 14,
  },
  passwordContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F7F0E7',
    borderWidth: 1,
    borderColor: '#EDE1D3',
    borderRadius: 14,
    marginBottom: 16,
  },
  passwordInput: {
    flex: 1,
    color: '#3A322B',
    fontFamily: 'Inter_400Regular',
    fontSize: 16,
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  eyeIcon: {
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  button: {
    backgroundColor: '#D98CA0',
    paddingVertical: 10,
    alignItems: 'center',
    borderRadius: 14,
    marginTop: 8,
  },
  buttonText: {
    fontFamily: 'Inter_700Bold',
    color: '#C25B6E',
    fontSize: 15,
  },
  linkButton: {
    marginTop: 16,
    alignItems: 'center',
    padding: 8,
  },
  linkText: {
    fontFamily: 'Inter_500Medium',
    color: '#D98CA0',
    fontSize: 14,
  },
  footerContainer: {
    alignItems: 'center',
    marginBottom: 10,
  },
  statusText: {
    fontFamily: 'IBMPlexMono_400Regular',
    color: '#8C7F72',
    fontSize: 12,
  },
  errorBanner: {
    backgroundColor: '#FEE2E2',
    padding: 12,
    borderRadius: 8,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: '#FCA5A5',
  },
  errorText: {
    color: '#991B1B',
    fontFamily: 'Inter_500Medium',
    fontSize: 14,
    textAlign: 'center',
  },
});
