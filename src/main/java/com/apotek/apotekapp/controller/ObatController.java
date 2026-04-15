package com.apotek.apotekapp.controller;

import com.apotek.apotekapp.entity.Obat;
import com.apotek.apotekapp.repository.ObatRepository;
import com.apotek.apotekapp.repository.SupplierRepository;
import com.apotek.apotekapp.repository.KategoriRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/obat")
public class ObatController {

    @Autowired
    private ObatRepository obatRepository;

    @Autowired
    private SupplierRepository supplierRepository;

    @Autowired
    private KategoriRepository kategoriRepository;

    // GET (ALL / FILTER BY KATEGORI)
    @GetMapping
    public List<Obat> getAll(
            @RequestParam(required = false) Long kategoriId
    ) {
        if (kategoriId != null) {
            return obatRepository.findByKategoriId(kategoriId);
        }
        return obatRepository.findAll();
    }

    // POST (CREATE)
    @PostMapping
    public Obat create(@RequestBody Obat obat) {

        // ambil kategori dari DB
        Long kategoriId = obat.getKategori().getId();
        obat.setKategori(
                kategoriRepository.findById(kategoriId).orElseThrow()
        );

        // ambil supplier dari DB
        Long supplierId = obat.getSupplier().getId();
        obat.setSupplier(
                supplierRepository.findById(supplierId).orElseThrow()
        );

        return obatRepository.save(obat);
    }

    // PUT (UPDATE)
    @PutMapping("/{id}")
    public Obat update(@PathVariable Long id, @RequestBody Obat newObat) {
        return obatRepository.findById(id).map(obat -> {

            obat.setNamaObat(newObat.getNamaObat());
            obat.setHarga(newObat.getHarga());
            obat.setStok(newObat.getStok());

            // kategori
            Long kategoriId = newObat.getKategori().getId();
            obat.setKategori(
                    kategoriRepository.findById(kategoriId).orElseThrow()
            );

            // supplier
            Long supplierId = newObat.getSupplier().getId();
            obat.setSupplier(
                    supplierRepository.findById(supplierId).orElseThrow()
            );

            return obatRepository.save(obat);
        }).orElseThrow();
    }

    // DELETE
    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        obatRepository.deleteById(id);
    }
}
