package com.kidsfashion.controller;

import com.kidsfashion.model.User;
import com.kidsfashion.service.UserService; // 1. Bác nhớ Import cái này nhé
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.security.Principal;

@Controller
@RequestMapping("/user") // Định nghĩa gốc là /user
public class UserController {

    @Autowired
    private UserService userService;

    // 1. Trang xem hồ sơ: /user/profile
    @GetMapping("/profile")
    public String showProfile(Model model, Principal principal) {
        String username = principal.getName();
        User user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Không thấy người dùng"));
        model.addAttribute("user", user);
        return "user/profile"; // Trả về file templates/user/profile.html
    }

    // 2. Trang sửa hồ sơ: /user/profile/edit (Bác đang thiếu hoặc sai chỗ này)
    @GetMapping("/profile/edit")
    public String editProfile(Model model, Principal principal) {
        String username = principal.getName();
        User user = userService.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Không thấy người dùng"));
        model.addAttribute("user", user);
        return "user/edit_profile"; // Trả về file templates/user/edit_profile.html
    }

    @PostMapping("/profile/update") // Phải là @PostMapping và khớp đường dẫn
    public String updateProfile(@ModelAttribute("user") User userDetails,
                                @RequestParam(value = "avatarFile", required = false) MultipartFile file,
                                Principal principal) {
        String username = principal.getName();
        userService.updateUser(username, userDetails, file);
        return "redirect:/user/profile?success"; // Sau khi lưu xong thì quay về trang profile
    }
}