"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useState } from "react";
import { SearchCommand } from "@/components/search-command";
import { useCompare } from "@/context/compare-context";

const links = [
  { href: "/telefonlar", label: "Katalog" },
  { href: "/karsilastir", label: "Kıyasla" },
];

export function Header() {
  const pathname = usePathname();
  const { phones } = useCompare();
  const [open, setOpen] = useState(false);
  const [searchKey, setSearchKey] = useState(0);

  const openSearch = () => {
    setSearchKey((value) => value + 1);
    setOpen(true);
  };

  useEffect(() => {
    const onKey = (event: KeyboardEvent) => {
      if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k") {
        event.preventDefault();
        setSearchKey((value) => value + 1);
        setOpen(true);
      }
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, []);

  return (
    <>
      <header className="site-header">
        <div className="shell header-inner">
          <Link href="/" className="logo">
            <span className="logo-mark">CK</span>
            <span>
              CepKıyas
              <small>Teknik puan + kullanıcı oyu</small>
            </span>
          </Link>

          <nav className="header-nav">
            {links.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className={pathname.startsWith(link.href) ? "active" : undefined}
              >
                {link.label}
                {link.href === "/karsilastir" && phones.length > 0 ? (
                  <b>{phones.length}</b>
                ) : null}
              </Link>
            ))}
          </nav>

          <button type="button" className="search-trigger" onClick={openSearch}>
            <span>Model veya yonga ara</span>
            <kbd>⌘K</kbd>
          </button>
        </div>
      </header>
      <SearchCommand key={searchKey} open={open} onClose={() => setOpen(false)} />
    </>
  );
}
