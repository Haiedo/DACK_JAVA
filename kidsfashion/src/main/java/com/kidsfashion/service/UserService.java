package com.kidsfashion.service;

import com.kidsfashion.model.Role;
import com.kidsfashion.model.User;
import com.kidsfashion.repository.RoleRepository;
import com.kidsfashion.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.*;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;
import org.springframework.web.multipart.MultipartFile; // BÁC NHỚ THÊM DÒNG NÀY
import java.io.IOException;
import java.nio.file.*;
import java.util.UUID;

@Service
@Transactional
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public User registerUser(User user) {
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        Role userRole = roleRepository.findByName("ROLE_USER")
                .orElseThrow(() -> new RuntimeException("Role not found"));
        user.getRoles().add(userRole);
        return userRepository.save(user);
    }

    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }

    public boolean existsByUsername(String username) {
        return userRepository.existsByUsername(username);
    }

    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    public User updateProfile(User user) {
        return userRepository.save(user);
    }

    public void changePassword(User user, String newPassword) {
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
    }

    // Admin
    public Page<User> searchUsers(String keyword, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        return userRepository.searchUsers(
                (keyword != null && !keyword.isBlank()) ? keyword : null, pageable);
    }

    public void toggleUserStatus(Long id) {
        userRepository.findById(id).ifPresent(u -> {
            u.setActive(!u.getActive());
            userRepository.save(u);
        });
    }

    public long countActiveUsers() {
        return userRepository.countByActiveTrue();
    }

    public User saveUser(User user) {
        return userRepository.save(user);
    }

    // Trong file UserService.java
    public void updateUser(String username, User userDetails, MultipartFile file) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng: " + username));

        // 1. Cập nhật thông tin cơ bản
        user.setFullName(userDetails.getFullName());
        user.setPhone(userDetails.getPhone());
        user.setAddress(userDetails.getAddress());

        // 2. Xử lý lưu File ảnh (Nếu có)
        if (file != null && !file.isEmpty()) {
            try {
                String uploadDir = "uploads/avatars/";
                Path uploadPath = Paths.get(uploadDir);
                if (!Files.exists(uploadPath)) {
                    Files.createDirectories(uploadPath);
                }

                String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
                Path filePath = uploadPath.resolve(fileName);
                Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

                user.setAvatarUrl("/uploads/avatars/" + fileName);
            } catch (IOException e) {
                throw new RuntimeException("Lỗi lưu ảnh bác Hải Nam ơi: " + e.getMessage());
            }
        }
        userRepository.save(user);
    }
}
