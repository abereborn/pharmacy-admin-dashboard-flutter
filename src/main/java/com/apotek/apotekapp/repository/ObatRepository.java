package com.apotek.apotekapp.repository;

import com.apotek.apotekapp.entity.Obat;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
public interface ObatRepository extends JpaRepository<Obat, Long> {

    List<Obat> findByKategoriId(Long kategoriId);

}

