import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function getMapUrl(lat: number, lng: number, name: string) {
  const isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
  const encodedName = encodeURIComponent(name);

  if (isMobile) {
    // Try Yandex Maps first as it's popular in Uzbekistan
    // We use a universal link that can open the app or fallback to browser
    return `https://yandex.com/maps/?pt=${lng},${lat}&z=16&l=map&text=${encodedName}`;
  } else {
    // Google Maps for desktop
    return `https://www.google.com/maps/search/?api=1&query=${lat},${lng}`;
  }
}
