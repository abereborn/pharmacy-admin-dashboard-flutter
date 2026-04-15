package com.apotek.apotekapp.controller;

import com.apotek.apotekapp.entity.Kategori;
import com.apotek.apotekapp.repository.KategoriRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/kategori")
@CrossOrigin // biar bisa diakses Flutter
public class KategoriController {

    @Autowired
    private KategoriRepository kategoriRepository;

    // ✅ GET semua kategori
    @GetMapping
    public List<Kategori> getAll() {
        return kategoriRepository.findAll();
    }

    // ✅ POST (tambah kategori)
    @PostMapping
    public Kategori create(@RequestBody Kategori kategori) {
        return kategoriRepository.save(kategori);
    }

    // ✅ DELETE kategori
    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        kategoriRepository.deleteById(id);
    }
}
