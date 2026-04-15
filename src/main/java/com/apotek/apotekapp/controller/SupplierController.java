package com.apotek.apotekapp.controller;

import com.apotek.apotekapp.entity.Supplier;
import com.apotek.apotekapp.repository.SupplierRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/supplier")
public class SupplierController {

    @Autowired
    private SupplierRepository supplierRepository;

    @GetMapping
    public List<Supplier> getAll() {
        return supplierRepository.findAll();
    }

    @PostMapping
    public Supplier create(@RequestBody Supplier supplier) {
        return supplierRepository.save(supplier);
    }

    @PutMapping("/{id}")
    public Supplier update(@PathVariable Long id, @RequestBody Supplier newSupplier) {
        return supplierRepository.findById(id).map(supplier -> {
            supplier.setNama(newSupplier.getNama());
            supplier.setAlamat(newSupplier.getAlamat());
            supplier.setNoHp(newSupplier.getNoHp());
            return supplierRepository.save(supplier);
        }).orElseThrow();
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        supplierRepository.deleteById(id);
    }
}
