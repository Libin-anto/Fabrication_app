import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
  ScrollView
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Feather } from '@expo/vector-icons';
import { createWorker, updateWorker } from '../services/api';
import PressableScale from '../components/PressableScale';

export default function WorkerForm({ route, navigation }: any) {
  const existingWorker = route.params?.worker;

  const [name, setName] = useState(existingWorker?.name || '');
  const [workerId, setWorkerId] = useState(existingWorker?.worker_id || '');
  const [role, setRole] = useState(existingWorker?.role || 'Fabricator');
  const [boxId, setBoxId] = useState(existingWorker?.box_id?.toString() || '1'); // Defaulting to 1 as requested in test
  
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSave = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const payload = {
        name,
        worker_id: workerId,
        role,
        box_id: parseInt(boxId, 10)
      };

      if (existingWorker) {
        await updateWorker(existingWorker.id, payload);
      } else {
        await createWorker({ ...payload, is_active: true });
      }
      
      navigation?.goBack();
    } catch (err: any) {
      setError(err.response?.data?.detail || err.message || 'Failed to save worker');
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView 
        style={{ flex: 1 }} 
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView contentContainerStyle={styles.scrollContent}>
          <View style={styles.header}>
            <TouchableOpacity 
              style={styles.backButton}
              onPress={() => navigation?.goBack()}
            >
              <Feather name="chevron-left" size={20} color="#3A322B" />
            </TouchableOpacity>
            <Text style={styles.sectionHeader}>{existingWorker ? 'Edit Worker' : 'New Worker'}</Text>
          </View>

          {error && (
            <View style={styles.errorContainer}>
              <Text style={styles.errorText}>{error}</Text>
            </View>
          )}

          <View style={styles.formPanel}>
            <View style={styles.inputGroup}>
              <Text style={styles.label}>FULL NAME</Text>
              <TextInput
                style={styles.input}
                value={name}
                onChangeText={setName}
                placeholder="e.g. John Doe"
                placeholderTextColor="#8C7F72"
              />
            </View>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>WORKER ID</Text>
              <TextInput
                style={styles.input}
                value={workerId}
                onChangeText={setWorkerId}
                placeholder="e.g. W-001"
                placeholderTextColor="#8C7F72"
              />
            </View>
            
            <View style={styles.inputGroup}>
              <Text style={styles.label}>BOX ID</Text>
              <TextInput
                style={styles.input}
                value={boxId}
                onChangeText={setBoxId}
                placeholder="e.g. 1"
                placeholderTextColor="#8C7F72"
                keyboardType="numeric"
              />
            </View>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>ROLE</Text>
              <View style={styles.roleContainer}>
                <TouchableOpacity 
                  style={[styles.roleButton, role === 'Fabricator' && styles.roleButtonActive]}
                  onPress={() => setRole('Fabricator')}
                >
                  <Text style={[styles.roleButtonText, role === 'Fabricator' && styles.roleButtonTextActive]}>
                    Fabricator
                  </Text>
                </TouchableOpacity>
                <TouchableOpacity 
                  style={[styles.roleButton, role === 'Helper' && styles.roleButtonActive]}
                  onPress={() => setRole('Helper')}
                >
                  <Text style={[styles.roleButtonText, role === 'Helper' && styles.roleButtonTextActive]}>
                    Helper
                  </Text>
                </TouchableOpacity>
              </View>
            </View>

            <PressableScale style={styles.saveButton} onPress={handleSave} disabled={loading}>
              {loading ? (
                <ActivityIndicator color="#C25B6E" />
              ) : (
                <Text style={styles.saveButtonText}>Save Worker</Text>
              )}
            </PressableScale>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F7F0E7',
  },
  scrollContent: {
    padding: 24,
  },
  header: {
    marginBottom: 32,
    flexDirection: 'row',
    alignItems: 'center',
  },
  backButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: '#EFE6D8',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
    borderWidth: 1,
    borderColor: '#EDE1D3',
  },
  sectionHeader: {
    fontFamily: 'Inter_700Bold',
    color: '#3A322B',
    fontSize: 24,
  },
  errorContainer: {
    backgroundColor: '#B94A4A',
    padding: 12,
    borderRadius: 14,
    marginBottom: 16,
  },
  errorText: {
    fontFamily: 'Inter_500Medium',
    color: '#FFFCF8',
    fontSize: 14,
    textAlign: 'center',
  },
  formPanel: {
    backgroundColor: '#FFFCF8',
    padding: 24,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#EDE1D3',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 3,
  },
  inputGroup: {
    marginBottom: 24,
  },
  label: {
    fontFamily: 'Inter_500Medium',
    color: '#8C7F72',
    fontSize: 12,
    letterSpacing: 1,
    marginBottom: 8,
  },
  input: {
    fontFamily: 'Inter_400Regular',
    backgroundColor: '#F7F0E7',
    color: '#3A322B',
    fontSize: 16,
    padding: 16,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#EDE1D3',
  },
  roleContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  roleButton: {
    flex: 1,
    paddingVertical: 10,
    backgroundColor: '#F7F0E7',
    borderWidth: 1,
    borderColor: '#EDE1D3',
    borderRadius: 14,
    alignItems: 'center',
    marginHorizontal: 4,
  },
  roleButtonActive: {
    backgroundColor: '#D98CA0',
    borderColor: '#D98CA0',
  },
  roleButtonText: {
    fontFamily: 'Inter_500Medium',
    color: '#8C7F72',
    fontSize: 14,
  },
  roleButtonTextActive: {
    color: '#C25B6E',
  },
  saveButton: {
    backgroundColor: '#D98CA0',
    paddingVertical: 10,
    borderRadius: 14,
    alignItems: 'center',
    marginTop: 16,
  },
  saveButtonText: {
    fontFamily: 'Inter_700Bold',
    color: '#C25B6E',
    fontSize: 15,
  },
});
