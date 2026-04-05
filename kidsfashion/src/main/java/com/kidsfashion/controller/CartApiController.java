package com.kidsfashion.controller;

import com.kidsfashion.model.User;
import com.kidsfashion.service.CartService;
import com.kidsfashion.service.UserService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/cart")
public class CartApiController {

    @Autowired
    private CartService cartService;

    @Autowired
    private UserService userService;

    private User getCurrentUser(Authentication auth) {
        if (auth == null || !auth.isAuthenticated() || auth.getName().equals("anonymousUser")) return null;
        return userService.findByUsername(auth.getName()).orElse(null);
    }

    @GetMapping("/count")
    public ResponseEntity<Map<String, Object>> getCartCount(
            Authentication auth, HttpSession session) {
        User user = getCurrentUser(auth);
        long count = cartService.getCartCount(user, session.getId());
        return ResponseEntity.ok(Map.of("count", count));
    }
}
