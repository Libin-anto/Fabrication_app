import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  ScrollView
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { useFocusEffect } from '@react-navigation/native';
import { getWorkers, getAvailableMachines, assignMachine, getCurrentAssignments } from '../services/api';
import PressableScale from '../components/PressableScale';
import { useExitAppOnBack } from '../hooks/useExitAppOnBack';

export default function AssignTool({ navigation }: any) {
  const [selectedWorker, setSelectedWorker] = useState<number | null>(null);
  const [selectedMachine, setSelectedMachine] = useState<number | null>(null);
  const [location, setLocation] = useState<string>('On Site');

  useExitAppOnBack();
  
  const [workers, setWorkers] = useState<any[]>([]);
  const [machines, setMachines] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [assignError, setAssignError] = useState<string | null>(null);
  const [showConfirm, setShowConfirm] = useState(false);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  const fetchData = async () => {
    try {
      setLoading(true);
      setError(null);
      setAssignError(null);
      
      const [workersData, machinesData, currentAssignmentsData] = await Promise.all([
        getWorkers(),
        getAvailableMachines(),
        getCurrentAssignments()
      ]);
      
      const assignedWorkerIds = new Set(currentAssignmentsData.map((a: any) => a.worker_id));
      const availableWorkers = workersData.filter(w => !assignedWorkerIds.has(w.id));
      
      setWorkers(availableWorkers);
      setMachines(machinesData);
    } catch (err: any) {
      setError(err.response?.data?.detail || err.message || 'Failed to fetch data');
    } finally {
      setLoading(false);
    }
  };

  useFocusEffect(
    useCallback(() => {
      fetchData();
    }, [])
  );

  const handleAssignInit = () => {
    if (!selectedWorker || !selectedMachine) return;
    setShowConfirm(true);
  };

  const handleAssignConfirm = async () => {
    setShowConfirm(false);
    if (!selectedWorker || !selectedMachine) return;
    
    try {
      setAssignError(null);
      await assignMachine(selectedWorker, selectedMachine, location);
      console.log(`[DIAGNOSTIC - ${new Date().toISOString()}] AssignTool assignMachine resolved`);
      
      const worker = workers.find(w => w.id === selectedWorker);
      setSuccessMessage(`Assigned to ${worker?.name || 'Worker'}`);
      
      setTimeout(() => {
        setSuccessMessage(null);
        setSelectedWorker(null);
        setSelectedMachine(null);
        setLocation('On Site');
        navigation?.navigate('Home');
      }, 1500);
    } catch (err: any) {
      setAssignError(err.response?.data?.detail || err.message || 'Assignment failed');
      fetchData();
    }
  };

  if (loading) {
    return (
      <View style={[styles.container, styles.centerAll]}>
        <ActivityIndicator size="large" color="#D98CA0" />
      </View>
    );
  }

  if (error) {
    return (
      <View style={[styles.container, styles.centerAll]}>
        <Text style={styles.errorText}>{error}</Text>
        <TouchableOpacity style={styles.retryButton} onPress={fetchData}>
          <Text style={styles.retryButtonText}>Retry</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.header}>
          <Text style={styles.sectionHeader}>New Assignment</Text>
        </View>

        {assignError && (
          <View style={styles.errorBanner}>
            <Text style={styles.errorBannerText}>{assignError}</Text>
          </View>
        )}

        {successMessage && (
          <View style={styles.successBanner}>
            <Text style={styles.successBannerText}>{successMessage}</Text>
          </View>
        )}

        <View style={styles.formPanel}>
          <View style={styles.section}>
            <Text style={styles.label}>SELECT WORKER</Text>
            {workers.map(worker => (
              <TouchableOpacity
                key={worker.id}
                style={[
                  styles.selectItem,
                  selectedWorker === worker.id && styles.selectItemActive
                ]}
                onPress={() => setSelectedWorker(worker.id)}
              >
                <Text style={[
                  styles.selectItemText,
                  selectedWorker === worker.id && styles.selectItemTextActive
                ]}>
                  {worker.name} ({worker.worker_id})
                </Text>
              </TouchableOpacity>
            ))}
          </View>

          <View style={styles.section}>
            <Text style={styles.label}>SELECT MACHINE</Text>
            {machines.map(machine => (
              <TouchableOpacity
                key={machine.id}
                style={[
                  styles.selectItem,
                  selectedMachine === machine.id && styles.selectItemActive
                ]}
                onPress={() => setSelectedMachine(machine.id)}
              >
                <Text style={[
                  styles.selectItemText,
                  selectedMachine === machine.id && styles.selectItemTextActive
                ]}>
                  {machine.name} ({machine.machine_id})
                </Text>
              </TouchableOpacity>
            ))}
          </View>

          <View style={styles.section}>
            <Text style={styles.label}>LOCATION</Text>
            <View style={styles.toggleGroup}>
              <TouchableOpacity
                style={[styles.toggleButton, location === 'On Site' && styles.toggleButtonActive]}
                onPress={() => setLocation('On Site')}
              >
                <Text style={[styles.toggleButtonText, location === 'On Site' && styles.toggleButtonTextActive]}>
                  On Site
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.toggleButton, location === 'With Worker' && styles.toggleButtonActive]}
                onPress={() => setLocation('With Worker')}
              >
                <Text style={[styles.toggleButtonText, location === 'With Worker' && styles.toggleButtonTextActive]}>
                  With Worker
                </Text>
              </TouchableOpacity>
            </View>
          </View>

          {showConfirm ? (
            <View style={styles.confirmContainer}>
              <Text style={styles.confirmText}>
                Assign {machines.find(m => m.id === selectedMachine)?.name} to {workers.find(w => w.id === selectedWorker)?.name}?
              </Text>
              <View style={styles.confirmActions}>
                <TouchableOpacity onPress={handleAssignConfirm}>
                  <Text style={styles.confirmYes}>YES</Text>
                </TouchableOpacity>
                <Text style={styles.confirmDivider}> / </Text>
                <TouchableOpacity onPress={() => setShowConfirm(false)}>
                  <Text style={styles.confirmNo}>NO</Text>
                </TouchableOpacity>
              </View>
            </View>
          ) : (
            <PressableScale 
              style={[styles.saveButton, (!selectedWorker || !selectedMachine) && styles.saveButtonDisabled]} 
              onPress={handleAssignInit}
              disabled={!selectedWorker || !selectedMachine}
            >
              <Text style={styles.saveButtonText}>Assign Tool</Text>
            </PressableScale>
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F7F0E7',
  },
  centerAll: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  scrollContent: {
    padding: 24,
  },
  header: {
    marginBottom: 32,
  },
  sectionHeader: {
    fontFamily: 'Inter_700Bold',
    color: '#3A322B',
    fontSize: 24,
  },
  errorBanner: {
    backgroundColor: '#B94A4A',
    padding: 12,
    borderRadius: 14,
    marginBottom: 16,
  },
  errorBannerText: {
    fontFamily: 'Inter_500Medium',
    color: '#FFFCF8',
    fontSize: 14,
  },
  successBanner: {
    backgroundColor: '#D98CA0',
    padding: 12,
    borderRadius: 14,
    marginBottom: 16,
  },
  successBannerText: {
    fontFamily: 'Inter_500Medium',
    color: '#FFFCF8',
    fontSize: 14,
  },
  errorText: {
    fontFamily: 'Inter_400Regular',
    color: '#B94A4A',
    fontSize: 16,
    marginBottom: 16,
    textAlign: 'center',
  },
  retryButton: {
    backgroundColor: '#EFE6D8',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 14,
  },
  retryButtonText: {
    fontFamily: 'Inter_700Bold',
    color: '#3A322B',
    fontSize: 14,
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
  section: {
    marginBottom: 24,
  },
  label: {
    fontFamily: 'Inter_500Medium',
    color: '#8C7F72',
    fontSize: 12,
    letterSpacing: 1,
    marginBottom: 12,
  },
  selectItem: {
    padding: 16,
    backgroundColor: '#F7F0E7',
    borderWidth: 1,
    borderColor: '#EDE1D3',
    borderRadius: 14,
    marginBottom: 8,
  },
  selectItemActive: {
    backgroundColor: '#D98CA0',
    borderColor: '#D98CA0',
  },
  selectItemText: {
    fontFamily: 'Inter_400Regular',
    color: '#8C7F72',
    fontSize: 16,
  },
  selectItemTextActive: {
    fontFamily: 'Inter_500Medium',
    color: '#C25B6E',
  },
  saveButton: {
    backgroundColor: '#D98CA0',
    paddingVertical: 10,
    borderRadius: 14,
    alignItems: 'center',
    marginTop: 16,
  },
  saveButtonDisabled: {
    backgroundColor: '#EDE1D3',
  },
  saveButtonText: {
    fontFamily: 'Inter_700Bold',
    color: '#C25B6E',
    fontSize: 15,
  },
  toggleGroup: {
    flexDirection: 'row',
    backgroundColor: '#F7F0E7',
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#EDE1D3',
    overflow: 'hidden',
  },
  toggleButton: {
    flex: 1,
    paddingVertical: 10,
    alignItems: 'center',
  },
  toggleButtonActive: {
    backgroundColor: '#D98CA0',
  },
  toggleButtonText: {
    fontFamily: 'Inter_500Medium',
    color: '#8C7F72',
    fontSize: 14,
  },
  toggleButtonTextActive: {
    color: '#C25B6E',
  },
  confirmContainer: {
    padding: 16,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: '#F7F0E7',
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#EDE1D3',
    marginTop: 16,
  },
  confirmText: {
    flex: 1,
    fontFamily: 'Inter_500Medium',
    color: '#3A322B',
    fontSize: 14,
    marginRight: 8,
  },
  confirmActions: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  confirmYes: {
    fontFamily: 'Inter_700Bold',
    color: '#B94A4A',
    fontSize: 14,
  },
  confirmNo: {
    fontFamily: 'Inter_700Bold',
    color: '#8C7F72',
    fontSize: 14,
  },
  confirmDivider: {
    color: '#EDE1D3',
    fontSize: 14,
    marginHorizontal: 8,
  },
});
