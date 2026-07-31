import React, { useEffect } from 'react';
import { View, ActivityIndicator, StyleSheet } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import * as SplashScreen from 'expo-splash-screen';
import { useFonts } from 'expo-font';
import { Inter_400Regular, Inter_500Medium, Inter_700Bold } from '@expo-google-fonts/inter';
import { IBMPlexMono_400Regular } from '@expo-google-fonts/ibm-plex-mono';
import { Feather } from '@expo/vector-icons';
import 'react-native-gesture-handler';

import Login from './src/screens/Login';
import Dashboard from './src/screens/Dashboard';
import WorkerList from './src/screens/WorkerList';
import WorkerForm from './src/screens/WorkerForm';
import MachineList from './src/screens/MachineList';
import MachineForm from './src/screens/MachineForm';
import AssignTool from './src/screens/AssignTool';
import Activity from './src/screens/Activity';
import SearchResults from './src/screens/SearchResults';

SplashScreen.preventAutoHideAsync();

const Stack = createStackNavigator();
const Tab = createBottomTabNavigator();
const WorkerStack = createStackNavigator();
const MachineStack = createStackNavigator();

function WorkerStackScreen() {
  return (
    <WorkerStack.Navigator screenOptions={{ headerShown: false }}>
      <WorkerStack.Screen name="WorkerList" component={WorkerList} />
      <WorkerStack.Screen name="WorkerForm" component={WorkerForm} />
      <WorkerStack.Screen name="SearchResults" component={SearchResults} />
    </WorkerStack.Navigator>
  );
}

function MachineStackScreen() {
  return (
    <MachineStack.Navigator screenOptions={{ headerShown: false }}>
      <MachineStack.Screen name="MachineList" component={MachineList} />
      <MachineStack.Screen name="MachineForm" component={MachineForm} />
      <MachineStack.Screen name="SearchResults" component={SearchResults} />
    </MachineStack.Navigator>
  );
}

function TabNavigator() {
  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        headerShown: false,
        tabBarStyle: {
          backgroundColor: '#FFFCF8',
          borderTopWidth: 1,
          borderTopColor: '#EDE1D3',
        },
        tabBarActiveTintColor: '#D98CA0',
        tabBarInactiveTintColor: '#8C7F72',
        tabBarIcon: ({ color, size }) => {
          let iconName: any = 'home';
          if (route.name === 'Home') iconName = 'home';
          else if (route.name === 'Workers') iconName = 'users';
          else if (route.name === 'Machines') iconName = 'tool';
          else if (route.name === 'Assign') iconName = 'plus-circle';
          else if (route.name === 'Activity') iconName = 'list';
          
          return <Feather name={iconName} size={size} color={color} />;
        },
      })}
    >
      <Tab.Screen name="Home" component={Dashboard} />
      <Tab.Screen name="Workers" component={WorkerStackScreen} />
      <Tab.Screen name="Machines" component={MachineStackScreen} />
      <Tab.Screen name="Assign" component={AssignTool} />
      <Tab.Screen name="Activity" component={Activity} />
    </Tab.Navigator>
  );
}

export default function App() {
  const [fontsLoaded] = useFonts({
    Inter_400Regular,
    Inter_500Medium,
    Inter_700Bold,
    IBMPlexMono_400Regular,
  });

  useEffect(() => {
    if (fontsLoaded) {
      SplashScreen.hideAsync();
    }
  }, [fontsLoaded]);

  if (!fontsLoaded) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color="#D98CA0" />
      </View>
    );
  }

  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Login">
        <Stack.Screen name="Login" component={Login} options={{ headerShown: false }} />
        <Stack.Screen name="Main" component={TabNavigator} options={{ headerShown: false }} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    backgroundColor: '#F7F0E7',
    justifyContent: 'center',
    alignItems: 'center',
  }
});
