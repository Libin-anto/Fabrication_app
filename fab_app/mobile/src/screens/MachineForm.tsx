import React, { useState } from 'react';
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
import { createMachine, updateMachine } from '../services/api';
import PressableScale from '../components/PressableScale';

export default function MachineForm({ route, navigation }: any) {
  const existingMachine = route.params?.machine;

  const [name, setName] = useState(existingMachine?.name || '');
  const [machineId, setMachineId] = useState(existingMachine?.machine_id || '');
  const [machineNumber, setMachineNumber] = useState(existingMachine?.machine_number || '');
  const [category, setCategory] = useState(existingMachine?.category || '');
  
  // Can only be Available or Under Repair manually
  const [status, setStatus] = useState(existingMachine?.status === 'Under Repair' ? 'Under Repair' : 'Available');

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSave = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const payload = {
        name,
        machine_id: machineId,
        machine_number: machineNumber,
        category,
        status
      };

      if (existingMachine) {
        await updateMachine(existingMachine.id, payload);
      } else {
        await createMachine({ ...payload, is_active: true });
      }
      
      navigation?.goBack();
    } catch (err: any) {
      setError(err.response?.data?.detail || err.message || 'Failed to save machine');
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
            <Text style={styles.sectionHeader}>{existingMachine ? 'Edit Machine' : 'New Machine'}</Text>
          </View>

          {error && (
            <View style={styles.errorContainer}>
              <Text style={styles.errorText}>{error}</Text>
            </View>
          )}

          <View style={styles.formPanel}>
            <View style={styles.inputGroup}>
              <Text style={styles.label}>MACHINE NAME</Text>
              <TextInput
                style={styles.input}
                value={name}
                onChangeText={setName}
                placeholder="e.g. Drill Press A"
                placeholderTextColor="#8C7F72"
              />
            </View>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>MACHINE ID</Text>
              <TextInput
                style={styles.input}
                value={machineId}
                onChangeText={setMachineId}
                placeholder="e.g. M-001"
                placeholderTextColor="#8C7F72"
              />
            </View>
            
            <View style={styles.inputGroup}>
              <Text style={styles.label}>MACHINE NUMBER</Text>
              <TextInput
                style={styles.input}
                value={machineNumber}
                onChangeText={setMachineNumber}
                placeholder="e.g. SN-998877"
                placeholderTextColor="#8C7F72"
              />
            </View>

            <View style={styles.inputGroup}>
              <Text style={styles.label}>CATEGORY</Text>
              <TextInput
                style={styles.input}
                value={category}
                onChangeText={setCategory}
                placeholder="e.g. Drilling"
                placeholderTextColor="#8C7F72"
              />
            </View>
            
            <View style={styles.inputGroup}>
              <Text style={styles.label}>STATUS</Text>
              <View style={styles.statusContainer}>
                <TouchableOpacity 
                  style={[styles.statusButton, status === 'Available' && styles.statusButtonActive]}
                  onPress={() => setStatus('Available')}
                >
                  <Text style={[styles.statusButtonText, status === 'Available' && styles.statusButtonTextActive]}>
                    Available
                  </Text>
                </TouchableOpacity>
                <TouchableOpacity 
                  style={[styles.statusButton, status === 'Under Repair' && styles.statusButtonRepairActive]}
                  onPress={() => setStatus('Under Repair')}
                >
                  <Text style={[styles.statusButtonText, status === 'Under Repair' && styles.statusButtonTextRepairActive]}>
                    Under Repair
                  </Text>
                </TouchableOpacity>
              </View>
            </View>

            <PressableScale style={styles.saveButton} onPress={handleSave} disabled={loading}>
              {loading ? (
                <ActivityIndicator color="#C25B6E" />
              ) : (
                <Text style={styles.saveButtonText}>Save Machine</Text>
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
  statusContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  statusButton: {
    flex: 1,
    paddingVertical: 10,
    backgroundColor: '#F7F0E7',
    borderWidth: 1,
    borderColor: '#EDE1D3',
    borderRadius: 14,
    alignItems: 'center',
    marginHorizontal: 4,
  },
  statusButtonActive: {
    backgroundColor: '#D98CA0',
    borderColor: '#D98CA0',
  },
  statusButtonRepairActive: {
    backgroundColor: '#B94A4A',
    borderColor: '#B94A4A',
  },
  statusButtonText: {
    fontFamily: 'Inter_500Medium',
    color: '#8C7F72',
    fontSize: 14,
  },
  statusButtonTextActive: {
    color: '#C25B6E',
  },
  statusButtonTextRepairActive: {
    color: '#FFFCF8',
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
