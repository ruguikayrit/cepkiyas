import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async redirects() {
    return [
      {
        source: "/telefonlar",
        destination: "/katalog/telefon",
        permanent: false,
      },
    ];
  },
};

export default nextConfig;
