shader_type canvas_item;

// Paramètres du shader
uniform int current_ammo : hint_range(0, 3) = 3;
uniform int angle_id : hint_range(1, 4) = 1;
uniform float normal_alpha : hint_range(0.0, 1.0) = 1.0;
uniform float transparent_alpha : hint_range(0.0, 1.0) = 0.3;
uniform vec4 tint_color : source_color = vec4(1.0); // <- Ajouté

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	bool should_be_transparent = false;

	if (current_ammo == 2 && angle_id == 1) {
		should_be_transparent = true;
	}
	else if (current_ammo == 1 && (angle_id == 1 || angle_id == 2)) {
		should_be_transparent = true;
	}
	else if (current_ammo == 0 && (angle_id == 1 || angle_id == 2 || angle_id == 3)) {
		should_be_transparent = true;
	}

	float alpha = should_be_transparent ? transparent_alpha : normal_alpha;
	COLOR = vec4(tint_color.rgb * tex_color.rgb, tex_color.a * alpha * tint_color.a);
}
