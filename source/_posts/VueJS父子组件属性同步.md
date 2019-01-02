# VueJS父子组件属性同步

## 背景

　　为了解决ElementUI中Dialog+Form同时用于添加、修改操作时，Form中输入项值及检验状态滞留（显示的是上一次关闭Dialog前的值）的问题。

　　在父组件中对Table行数据进行`添加`、`修改`操作，使用了ElementUI的Dialog组件，`添加`、`修改`操作使用同一Dialog表单。那么问题来了，点击`添加`按钮时，对话框表单输入项初始化状态都应置空；点击`修改`按钮对话框表单输入项应初始化为当前行的值；另外，我给表单加了ElementUI自带的输入校验。

　　Dialog关闭时，仅设置了`display:none`属性。每次Dialog显示时都会遗留上一次关闭之前的值或者校验提示状态。虽然可以在代码中显示重置表单各项数据，以及通过`this.$refs['form'].resetForm()`、`this.$refs['form'].clearValidate()`重置表单校验状态，但是`this.$refs['form'].resetForm()`重置后的表单值始终为第一次打开Dialog时的值。

<!-- more -->

## 解决方案

&#160; &#160; &#160; 我将Dialog+表单封装为组件。在父组件中引用子组件时添加`v-if`，在关闭Dialog时将子组件销毁。

### 核心代码



```html
<!-- 子组件Dialog关闭时向父组件发送事件 -->
<script>
    this.$emit('update', this.isRender)
</script>

<!-- 父组件使用@update接受子组件事件，并更新对话框显示 -->
<menu-form-dialog v-if="dialogVisible" :render="dialogVisible" :form="form" :title="dialogTitle" @update="updateDialogVisible"/>
```

### 父组件

```html
<template>
  <div class="app-container">
    <tree-table :data="data" :columns="columns" :expand-all="true" border>
      <el-table-column :label="$t('app.common.opt')" width="250" align="center">
        <template slot-scope="scope">
          <el-button size="mini" type="success" @click="openAddDialog">{{ $t('app.common.add') }}</el-button>
          <el-button size="mini" type="primary" @click="openEditDialog(scope.row)">{{ $t('app.common.edit') }}</el-button>
          <el-button size="mini" type="danger">{{ $t('app.common.del') }}</el-button>
        </template>
      </el-table-column>
    </tree-table>
    <menu-form-dialog v-if="dialogVisible" :render="dialogVisible" :form="form" :title="dialogTitle" @update="updateDialogVisible"/>
  </div>
</template>

<script>
import treeTable from '@/components/TreeTable'
import { getWebMenuList } from '@/api/sys/webmenu'
import menuFormDialog from './menu-form'

export default {
  name: 'WebMenu',
  components: { treeTable, menuFormDialog },
  data() {
    return {
      dialogVisible: false,
      dialogTitle: '',
      form: {
        parentId: '',
        name: '',
        href: '',
        sort: 0,
        isShow: '',
        remarks: ''
      },
      columns: [
        {
          text: 'app.system.system.webmenu.name',
          value: 'remarks',
          width: 300
        },
        {
          text: 'app.system.system.webmenu.i18nCode',
          value: 'name'
        },
        {
          text: 'app.system.system.webmenu.link',
          value: 'href',
          type: 'link'
        },
        {
          text: 'app.system.system.webmenu.sort',
          value: 'sort',
          width: 100
        },
        {
          text: 'app.system.system.webmenu.nodeType',
          value: 'isShow',
          width: 100,
          formatter: this.nodeTypeFormatter
        }
      ],
      data: []
    }
  },
  mounted() {
    this.initTable()
  },
  methods: {
    initTable() {
      getWebMenuList().then(response => {
        this.data = this.buildTreeData(response.data)
      })
    },
    buildTreeData(list) {
      console.time('buildTreeData')
      const temp = {}
      const tree = []
      for (const i in list) {
        temp[list[i].id] = list[i]
        delete temp[list[i].id].parent
        if (temp[list[i].id].parentId === 1) {
          temp[list[i].id]['pid'] = temp[list[i].id].parentId
          delete temp[list[i].id].parentId
        }
      }
      for (const i in temp) {
        if (temp[i].parentId) {
          if (!temp[temp[i].parentId].children) {
            temp[temp[i].parentId]['children'] = []
          }
          temp[temp[i].parentId].children.push(temp[i])
        } else {
          tree.push(temp[i])
        }
      }
      this.sortTree(tree)
      console.timeEnd('buildTreeData')
      return tree
    },
    sortTree(tree) {
      tree.sort((a, b) => a.sort - b.sort)
      for (const i in tree) {
        if (tree[i].children && tree[i].children.length > 0) {
          this.sortTree(tree[i].children)
        }
      }
    },
    nodeTypeFormatter(value) {
      let nodeType
      value = parseInt(value)
      switch (value) {
        case 0:
          nodeType = this.$t('app.system.system.webmenu.nodeTypeFunc')
          break
        case 1:
          nodeType = this.$t('app.system.system.webmenu.nodeTypeMenu')
          break
        default:
          nodeType = value
          break
      }
      return nodeType
    },
    openAddDialog() {
      this.form.parentId = ''
      this.form.name = ''
      this.form.href = ''
      this.form.sort = 0
      this.form.isShow = ''
      this.form.remarks = ''
      this.title = '添加'
      this.dialogVisible = true
    },
    openEditDialog(row) {
      this.form.parentId = row.parentId || row.pid
      this.form.name = row.name
      this.form.href = row.href
      this.form.sort = row.sort
      this.form.isShow = row.isShow
      this.form.remarks = row.remarks
      this.title = '编辑'
      this.dialogVisible = true
    },
    updateDialogVisible(val) {
      this.dialogVisible = val
    }
  }
}
</script>
```

### 子组件

```html
<template>
  <el-dialog v-el-drag-dialog :visible.sync="render" :title="title" :before-close="closeDialog" width="30%" @dragDialog="handleDrag">
    <el-form ref="form" :model="form" :rules="rules" status-icon label-width="80px">
      <el-form-item label="上级菜单" prop="parentId">
        <el-input v-model="form.parentId" clearable/>
      </el-form-item>
      <el-form-item label="名称" prop="name">
        <el-input v-model="form.name" placeholder="请输入i18n编码" clearable/>
      </el-form-item>
      <el-form-item label="链接" prop="href">
        <el-input v-model="form.href" placeholder="http://stock.jd.id" clearable/>
      </el-form-item>
      <el-form-item label="排序" prop="sort">
        <el-input-number v-model="form.sort" :min="0" :max="1000"/>
      </el-form-item>
      <el-form-item label="节点类型" prop="isShow">
        <el-radio-group v-model="form.isShow">
          <el-radio label="0">功能点</el-radio>
          <el-radio label="1">菜单</el-radio>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="备注" prop="remarks">
        <el-input v-model="form.remarks" type="textarea" clearable/>
      </el-form-item>
    </el-form>
    <span slot="footer" class="dialog-footer">
      <el-button type="primary" @click="submitForm">保存</el-button>
      <el-button @click="resetForm">重置</el-button>
    </span>
  </el-dialog>
</template>

<script>
import elDragDialog from '@/directive/el-dragDialog'
export default {
  name: 'MenuFormDialog',
  directives: { elDragDialog },
  props: {
    /* eslint-disable */
    title: String,
    form: Object,
    render: {
      type: Boolean,
      default: false
    }
  },
  data() {
    const pattern = {
      url: new RegExp('^(?!mailto:)(?:(?:http|https)://|//)(?:\\S+(?::\\S*)?@)?(?:(?:(?:[1-9]\\d?|1\\d\\d|2[01]\\d|22[0-3])(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}(?:\\.(?:[0-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))|(?:(?:[a-z\\u00a1-\\uffff0-9]+-?)*[a-z\\u00a1-\\uffff0-9]+)(?:\\.(?:[a-z\\u00a1-\\uffff0-9]+-?)*[a-z\\u00a1-\\uffff0-9]+)*(?:\\.(?:[a-z\\u00a1-\\uffff]{2,})))|localhost)(?::\\d{2,5})?(?:(/|\\?|#)[^\\s]*)?$', 'i')
    }
    const checkHref = (rule, value, callback) => {
      if (typeof (value) === 'string' && !!value.match(pattern.url)) {
        callback()
      } else {
        callback(new Error('请输入http或https格式'))
      }
    }
    return {
      visible: this.render,
      rules: {
        parentId: [
          { required: true, message: '请选择父级菜单', trigger: 'blur' }
        ],
        name: [
          { required: true, message: '请输入菜单i18n编码', trigger: 'blur' }
        ],
        href: [
          { required: true, message: '请输入菜单链接', trigger: 'blur' },
          { validator: checkHref, trigger: 'blur' }
        ],
        sort: [
          { required: true, message: '请输入菜单排序', trigger: 'blur' }
        ],
        isShow: [
          { required: true, message: '请选择节点类型', trigger: 'change' }
        ],
        remarks: [
          { required: true, message: '请输入备注信息', trigger: 'blur' }
        ]
      }
    }
  },
  methods: {
    handleDrag() {},
    submitForm() {
      this.$refs['form'].validate((valid) => {
        if (valid) {
          alert('submit!')
        } else {
          console.log('error submit!!')
          return false
        }
      })
    },
    resetForm() {
      this.$refs['form'].resetFields()
    },
    closeDialog(done) {
      this.$refs['form'].clearValidate()
      done()
      this.$emit('update', this.isRender)
    }
  }
}
</script>
```