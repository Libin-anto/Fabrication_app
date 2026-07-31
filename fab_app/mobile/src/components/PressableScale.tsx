import React, { useRef } from 'react';
import { Animated, Pressable, PressableProps } from 'react-native';

interface PressableScaleProps extends PressableProps {
  children: React.ReactNode;
  activeScale?: number;
}

export default function PressableScale({ children, activeScale = 0.96, ...props }: PressableScaleProps) {
  const scaleAnim = useRef(new Animated.Value(1)).current;

  const handlePressIn = (e: any) => {
    Animated.spring(scaleAnim, {
      toValue: activeScale,
      useNativeDriver: true,
      speed: 20,
      bounciness: 4,
    }).start();
    if (props.onPressIn) {
      props.onPressIn(e);
    }
  };

  const handlePressOut = (e: any) => {
    Animated.spring(scaleAnim, {
      toValue: 1,
      useNativeDriver: true,
      speed: 20,
      bounciness: 4,
    }).start();
    if (props.onPressOut) {
      props.onPressOut(e);
    }
  };

  return (
    <Pressable
      {...props}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
    >
      <Animated.View style={[{ transform: [{ scale: scaleAnim }] }, props.style as any]}>
        {children}
      </Animated.View>
    </Pressable>
  );
}
