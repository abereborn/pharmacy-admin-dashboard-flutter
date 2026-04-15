package com.apotek.apotekapp.entity;

import jakarta.persistence.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "obat")
public class Obat {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String namaObat;

    @ManyToOne
    @JoinColumn(name = "kategori_id")
    private Kategori kategori;
    @ManyToOne
    @JoinColumn(name = "supplier_id")
    private Supplier supplier;

    private int harga;
    private int stok;
}
