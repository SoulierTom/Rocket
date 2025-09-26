shader_type canvas_item;

// Paramètres du shader
uniform int current_ammo : hint_range(0, 4) = 4;
uniform int angle_id : hint_range(1, 8) = 1;
uniform float normal_alpha : hint_range(0.0, 1.0) = 1.0;
uniform float transparent_alpha : hint_range(0.0, 1.0) = 0.3;
uniform vec4 tint_color : source_color = vec4(1.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	bool should_be_transparent = false;

	// Logique de transparence pour tous les éléments
	// angle_id 1-4: CursorAngle 1-4
	// angle_id 5: CursorMiddle
	// angle_id 6-8: Carré 1-3

	if (current_ammo == 3) {
		// Avec 3 munitions, seul l'angle 1 devient transparent
		if (angle_id == 1) {
			should_be_transparent = true;
		}
	}
	else if (current_ammo == 2) {
		// Avec 2 munitions, les angles 1 et 2 deviennent transparents
		if (angle_id == 1 || angle_id == 2) {
			should_be_transparent = true;
		}
	}
	else if (current_ammo == 1) {
		// Avec 1 munition, les angles 1, 2 et 3 deviennent transparents
		if (angle_id == 1 || angle_id == 2 || angle_id == 3) {
			should_be_transparent = true;
		}
	}
	else if (current_ammo == 0) {
		// Avec 0 munition, tous les éléments deviennent transparents
		if (angle_id >= 1 && angle_id <= 8) {
			should_be_transparent = true;
		}
	}

	float alpha = should_be_transparent ? transparent_alpha : normal_alpha;
	COLOR = vec4(tint_color.rgb * tex_color.rgb, tex_color.a * alpha * tint_color.a);
}