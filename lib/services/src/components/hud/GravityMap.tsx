import React, { useEffect, useRef } from 'react';

// Define the Node interface based on our Supabase schema
interface FanNode {
  fan_id: string;
  lifetime_cleared_spend: number;
  dynamic_engagement_score: number; // Drives distance from center
}

export const GravityMap = ({ creatorId, fans }: { creatorId: string, fans: FanNode[] }) => {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // Center coordinates (The Creator)
    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;

    // Clear canvas for animation frame
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Draw Creator Node (Center)
    ctx.beginPath();
    ctx.arc(centerX, centerY, 30, 0, 2 * Math.PI);
    ctx.fillStyle = '#FFD700'; // Gold center
    ctx.fill();

    // Map the Fan Nodes (nides)
    fans.forEach((fan) => {
      // Calculate distance based on time-decay (lower score = further away)
      const maxOrbit = 300;
      const orbitDistance = maxOrbit - (fan.dynamic_engagement_score * 10); 
      
      // Calculate size based on total spend
      const nodeSize = Math.max(3, fan.lifetime_cleared_spend / 100); 

      // Random angle for orbit position
      const angle = Math.random() * Math.PI * 2;
      const nodeX = centerX + orbitDistance * Math.cos(angle);
      const nodeY = centerY + orbitDistance * Math.sin(angle);

      // Draw Fan Node
      ctx.beginPath();
      ctx.arc(nodeX, nodeY, nodeSize, 0, 2 * Math.PI);
      ctx.fillStyle = '#00E5FF'; // Cyber blue nodes
      ctx.fill();
    });
  }, [fans]);

  return (
    <div className="w-full h-full bg-slate-900 rounded-xl border border-slate-700 overflow-hidden">
      <canvas 
        ref={canvasRef} 
        width={800} 
        height={600} 
        className="w-full h-full"
      />
    </div>
  );
};