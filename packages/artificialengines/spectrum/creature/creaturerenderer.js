/******************************************************************************
 * Creature Runtimes License
 * 
 * Copyright (c) 2015, Kestrel Moon Studios
 * All rights reserved.
 * 
 * Preamble: This Agreement governs the relationship between Licensee and Kestrel Moon Studios(Hereinafter: Licensor).
 * This Agreement sets the terms, rights, restrictions and obligations on using [Creature Runtimes] (hereinafter: The Software) created and owned by Licensor,
 * as detailed herein:
 * License Grant: Licensor hereby grants Licensee a Sublicensable, Non-assignable & non-transferable, Commercial, Royalty free,
 * Including the rights to create but not distribute derivative works, Non-exclusive license, all with accordance with the terms set forth and
 * other legal restrictions set forth in 3rd party software used while running Software.
 * Limited: Licensee may use Software for the purpose of:
 * Running Software on Licensee’s Website[s] and Server[s];
 * Allowing 3rd Parties to run Software on Licensee’s Website[s] and Server[s];
 * Publishing Software’s output to Licensee and 3rd Parties;
 * Distribute verbatim copies of Software’s output (including compiled binaries);
 * Modify Software to suit Licensee’s needs and specifications.
 * Binary Restricted: Licensee may sublicense Software as a part of a larger work containing more than Software,
 * distributed solely in Object or Binary form under a personal, non-sublicensable, limited license. Such redistribution shall be limited to unlimited codebases.
 * Non Assignable & Non-Transferable: Licensee may not assign or transfer his rights and duties under this license.
 * Commercial, Royalty Free: Licensee may use Software for any purpose, including paid-services, without any royalties
 * Including the Right to Create Derivative Works: Licensee may create derivative works based on Software, 
 * including amending Software’s source code, modifying it, integrating it into a larger work or removing portions of Software, 
 * as long as no distribution of the derivative works is made
 * 
 * THE RUNTIMES IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE RUNTIMES OR THE USE OR OTHER DEALINGS IN THE
 * RUNTIMES.
 *****************************************************************************/

function CreatureRenderer(name, manager_in, material_in)
{
	this.creature_manager = manager_in;
	this.material = material_in;
	this.name = name;
	this.normals = [];
	
	this.renderMesh = null; 	

	if(this.renderMesh == null)
	{
		var target_creature = this.creature_manager.target_creature;
		var geometry = new THREE.BufferGeometry();
		var material = this.material;
		
		var vertices = new Float32Array(target_creature.total_num_pts * 3 );
		var normals = new Float32Array(target_creature.total_num_pts * 3 );
		var uvs = new Float32Array(target_creature.total_num_pts * 2 );
		var indices = new Uint32Array(target_creature.global_indices.length);
		
		// topology
		for(var i = 0; i < target_creature.global_indices.length; i++)
		{
			indices[i] = target_creature.global_indices[i];
		}
		
		// points
		for(var i = 0; i < target_creature.total_num_pts * 3; i++)
		{
			vertices[i] = target_creature.global_pts[i];
		}
		
		// uvs
		for(var i = 0; i < target_creature.total_num_pts * 2; i++)
		{
			uvs[i] = target_creature.global_uvs[i];
		}
		
		// normals
		for(var i = 0; i < target_creature.total_num_pts * 3; i+=3)
		{
			normals[i] = 0.0;
			normals[i + 1] = 0.0;
			normals[i + 2] = 0.0;
		}
				
		/*
		// colors
		for(var i = 0; i < target_creature.total_num_pts * 4; i+=4)
		{
			var cur_color = new THREE.Color(0xffffff);
			cur_color.setRGB(1,1,1);
			geometry.colors.push(cur_color);
		}
		*/
		
		geometry.setIndex( new THREE.BufferAttribute( indices, 1 ) );
		geometry.addAttribute( 'position', new THREE.BufferAttribute( vertices, 3 ) );
		geometry.addAttribute( 'normal', new THREE.BufferAttribute( normals, 3 ) );
		geometry.addAttribute( 'uv', new THREE.BufferAttribute( uvs, 2 ) );
		
		this.renderMesh = new THREE.Mesh(geometry, material);

		this.renderMesh.geometry.computeFaceNormals();		
		this.renderMesh.geometry.computeVertexNormals();	
		
		this.renderMesh.geometry.elementsNeedUpdate = true;	
		this.renderMesh.geometry.normalsNeedUpdate = true;	
		//this.renderMesh.geometry.colorsNeedUpdate = true;
		material.needsUpdate = true;
		this.renderMesh.geometry.verticesNeedUpdate = true;
		this.renderMesh.geometry.uvsNeedUpdate = true;
		this.renderMesh.geometry.buffersNeedUpdate = true;
	}

};

Artificial.Spectrum.CreatureRenderer = CreatureRenderer

CreatureRenderer.prototype.UpdateData = function()
{	
	var target_creature = this.creature_manager.target_creature;
	
	var read_pts = target_creature.render_pts;
	//var read_pts = target_creature.global_pts;
	var read_uvs = target_creature.global_uvs;
	var read_colours = target_creature.render_colours;
	
	// points
	var index = 0;
	set_vertices = this.renderMesh.geometry.getAttribute("position");
	set_vertices.needsUpdate = true;
	for(var i = 0; i < target_creature.total_num_pts * 3; i++)
	{
    if (i % 3 == 2) {
      set_vertices.array[i] = -target_creature.render_pts[i];
    } else {
      set_vertices.array[i] = target_creature.render_pts[i];
    }
	}
	
	// uvs
	set_uvs = this.renderMesh.geometry.getAttribute("uv");
	set_uvs.needsUpdate = true;
	for(var i = 0; i < target_creature.total_num_pts * 2; i+=2)
	{
		set_uvs.array[i] = target_creature.global_uvs[i];
		set_uvs.array[i + 1] = 1.0 - target_creature.global_uvs[i + 1];
	}
	
	this.renderMesh.geometry.verticesNeedUpdate = true;
	this.renderMesh.geometry.uvsNeedUpdate = true;
};
