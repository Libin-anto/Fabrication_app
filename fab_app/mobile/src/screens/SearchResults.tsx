import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  FlatList,
  StyleSheet,
  ActivityIndicator,
  TouchableOpacity
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Feather } from '@expo/vector-icons';
import { searchGlobal } from '../services/api';

export default function SearchResults({ route, navigation }: any) {
  const query = route.params?.query || '';
  const [results, setResults] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchResults = async () => {
      try {
        setLoading(true);
        setError(null);
        const data = await searchGlobal(query);
        setResults(data);
      } catch (err: any) {
        setError(err.message || 'Search failed');
      } finally {
        setLoading(false);
      }
    };
    
    if (query) {
      fetchResults();
    } else {
      setLoading(false);
    }
  }, [query]);

  const renderItem = ({ item }: { item: any }) => {
    if (item.type === 'worker') {
      return (
        <View style={styles.card}>
          <View style={styles.cardHeader}>
            <View style={styles.titleContainer}>
              <Feather name="user" size={16} color="#8C7F72" style={styles.icon} />
              <Text style={styles.itemName}>{item.name}</Text>
            </View>
            <Text style={styles.badgeText}>Worker</Text>
          </View>
          <View style={styles.cardDetails}>
            <Text style={styles.detailText}>ID: {item.display_id}</Text>
            <Text style={styles.detailText}>Role: {item.role}</Text>
          </View>
        </View>
      );
    } else {
      return (
        <View style={styles.card}>
          <View style={styles.cardHeader}>
            <View style={styles.titleContainer}>
              <Feather name="tool" size={16} color="#8C7F72" style={styles.icon} />
              <Text style={styles.itemName}>{item.name}</Text>
            </View>
            <Text style={styles.badgeText}>Machine</Text>
          </View>
          <View style={styles.cardDetails}>
            <Text style={styles.detailText}>ID: {item.display_id}</Text>
            <Text style={styles.detailText}>Status: {item.status}</Text>
          </View>
        </View>
      );
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity 
          style={styles.backButton}
          onPress={() => navigation?.goBack()}
        >
          <Feather name="chevron-left" size={20} color="#3A322B" />
        </TouchableOpacity>
        <Text style={styles.sectionHeader} numberOfLines={1}>Search: "{query}"</Text>
      </View>

      {loading ? (
        <View style={styles.centerAll}>
          <ActivityIndicator size="large" color="#D98CA0" />
        </View>
      ) : error ? (
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>{error}</Text>
        </View>
      ) : (
        <FlatList
          data={results}
          keyExtractor={(item) => `${item.type}-${item.id}`}
          renderItem={renderItem}
          contentContainerStyle={styles.listContent}
          ListEmptyComponent={
            <View style={styles.emptyState}>
              <Text style={styles.emptyStateText}>No results found</Text>
            </View>
          }
        />
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F7F0E7',
  },
  centerAll: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 24,
    paddingBottom: 16,
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
    flex: 1,
    fontFamily: 'Inter_700Bold',
    color: '#3A322B',
    fontSize: 24,
  },
  listContent: {
    paddingHorizontal: 24,
    paddingBottom: 40,
    flexGrow: 1,
  },
  card: {
    backgroundColor: '#FFFCF8',
    padding: 16,
    marginBottom: 12,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: '#EDE1D3',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 8,
    elevation: 3,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  titleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  icon: {
    marginRight: 8,
  },
  itemName: {
    fontFamily: 'Inter_700Bold',
    color: '#3A322B',
    fontSize: 16,
  },
  badgeText: {
    fontFamily: 'Inter_500Medium',
    color: '#8C7F72',
    fontSize: 12,
  },
  cardDetails: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingTop: 8,
    borderTopWidth: 1,
    borderTopColor: '#EDE1D3',
  },
  detailText: {
    fontFamily: 'IBMPlexMono_400Regular',
    color: '#8C7F72',
    fontSize: 12,
  },
  emptyState: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingTop: 40,
  },
  emptyStateText: {
    fontFamily: 'Inter_400Regular',
    color: '#8C7F72',
    fontSize: 16,
  },
  errorContainer: {
    paddingHorizontal: 24,
    paddingBottom: 16,
    alignItems: 'center',
  },
  errorText: {
    fontFamily: 'Inter_400Regular',
    color: '#B94A4A',
    fontSize: 14,
    textAlign: 'center',
  },
});
