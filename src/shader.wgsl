@vertex
fn vs_no_buffer(@builtin(vertex_index) index: u32) -> @builtin(position) vec4f {
    var p = vec2f(0.0, 0.0);
    if (index == 0u) {
        p = vec2f(-0.5, -0.5);
    } else if (index == 1u) {
        p = vec2f(0.5, -0.5);
    } else {
        p = vec2f(0.0, 0.5);
    }

    return vec4f(p, 0.0, 1.0);
}

@fragment
fn fs_hard_color() -> @location(0) vec4f {
    return vec4f(0.0, 0.4, 1.0, 1.0);
}

@vertex
fn vs_one_buf(@location(0) pos: vec2f) -> @builtin(position) vec4f {
    return vec4f(pos, 0.0, 1.0);
}

struct VertexInput {
    @location(0) position: vec2f,
    @location(1) color: vec3f
};

struct VertexOutput {
    @builtin(position) position: vec4f,
    @location(0) color: vec3f,
};

@vertex
fn vs_inter_buf(in: VertexInput) -> VertexOutput {
    let ratio = 1600.0 / 1200.0;
    var out: VertexOutput;
    out.position = vec4f(in.position.x, in.position.y * ratio, 0.0, 1.0);
    out.color = in.color;
    return out;
}

@fragment
fn fs_inter_buf(in: VertexOutput) -> @location(0) vec4f {
    return vec4f(in.color, 1.0);
}


@vertex
fn vs_file(in: VertexInput) -> VertexOutput {
    let ratio = 1600.0 / 1200.0;
    let offset = vec2f(-0.6875, -0.463);
    var out: VertexOutput;
    out.position = vec4f(in.position.x + offset.x, (in.position.y + offset.y) * ratio, 0.0, 1.0);
    out.color = in.color;
    return out;
}

@fragment
fn fs_file(in: VertexOutput) -> @location(0) vec4f {
    let linear_color = pow(in.color, vec3f(2.4));
    return vec4f(linear_color, 1.0);
}
