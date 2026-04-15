package com.apotek.apotekapp.controller;

import com.apotek.apotekapp.entity.User;
import com.apotek.apotekapp.repository.UserRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/login")
    public Map<String, Object> login(@RequestBody User request) {

        User user = userRepository.findByUsername(request.getUsername())
                .orElse(null);

        if (user != null && user.getPassword().equals(request.getPassword())) {
            return Map.of(
                    "success", true,
                    "message", "Login berhasil"
            );
        }

        return Map.of(
                "success", false,
                "message", "Username / Password salah"
        );
    }

    // 🔥 TAMBAH INI
    @PostMapping("/register")
    public User register(@RequestBody User user) {
        return userRepository.save(user);
    }
}

